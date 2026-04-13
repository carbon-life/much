# 三 数据处理

# 3.1 数据导入
CREATE DATABASE IF  NOT EXISTS my_database;
USE my_database;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopping_trends.csv'
INTO TABLE shopping_trends
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
-- 创建用户购物行为表（字段对应shopping_trends.csv的18个列，类型适配数据）
CREATE TABLE IF NOT EXISTS shopping_trends (
    customer_id INT COMMENT '用户ID（唯一标识）',
    age INT COMMENT '用户年龄',
    gender VARCHAR(10) COMMENT '用户性别（Male/Female）',
    item_purchased VARCHAR(50) COMMENT '购买商品名称',
    category VARCHAR(30) COMMENT '商品类目（如Clothing/Footwear）',
    purchase_amount_usd INT COMMENT '购买金额（美元）',
    location VARCHAR(50) COMMENT '用户所在地区',
    size VARCHAR(5) COMMENT '商品尺寸（S/M/L等）',
    color VARCHAR(20) COMMENT '商品颜色',
    season VARCHAR(10) COMMENT '购买季节（Spring/Summer等）',
    review_rating DECIMAL(2,1) COMMENT '商品评分（1-5分）',
    subscription_status VARCHAR(10) COMMENT '订阅状态（Yes/No）',
    shipping_type VARCHAR(20) COMMENT '配送类型（Express/Free Shipping等）',
    discount_applied VARCHAR(10) COMMENT '是否使用折扣（Yes/No）',
    promo_code_used VARCHAR(10) COMMENT '是否使用优惠码（Yes/No）',
    previous_purchases INT COMMENT '历史购买次数',
    payment_method VARCHAR(20) COMMENT '支付方式（Venmo/Credit Card等）',
    frequency_of_purchases VARCHAR(20) COMMENT '购买频率（Weekly/Monthly等）',
    -- 添加主键（可选，提升查询效率）
    PRIMARY KEY (customer_id, item_purchased, purchase_amount_usd)
) COMMENT '购物趋势分析-用户购物行为数据表';

# 3.2 数据如处理

# 3.2.1查看数据
USE my_database;
SELECT * FROM shopping_trends LIMIT 10; -- 查看前10行数据

# 3.2.2缺失值检测和处理
SELECT * FROM shopping_trends 
WHERE customer_id IS NULL 
OR age IS NULL
OR gender IS NULL
OR item_purchased IS NULL
OR category IS NULL
OR purchase_amount IS NULL
OR location IS NULL
OR size IS NULL
OR color IS NULL
OR season IS NULL
OR review_rating IS NULL
OR subscription_status IS NULL
OR shipping_type IS NULL
OR discount_applied IS NULL
OR promo_code_used IS NULL
OR previous_purchases IS NULL
OR payment_method IS NULL
OR frequency_of_purchases IS NULL;
-- 显示无缺失值

# 3.2.3 重复值检测和处理
SELECT * FROM shopping_trends
GROUP BY customer_id ,age ,gender,
item_purchased,category,purchase_amount,
location ,size,color,season,
review_rating,subscription_status ,shipping_type,
discount_applied ,promo_code_used,previous_purchases,
payment_method,frequency_of_purchases 
HAVING (COUNT(*)>1); -- 显示无重复值
# 四、数据分析
# 4.1 用户基本特征分析
/* 通过描述性统计和可视化手段，对用户的年龄分布(Age)、
性别比例(Gender)及地域集中度地域(Location)进行分析，
呈现出用户群体的轮廓特征。*/

# 4.1.1 年龄分布
SELECT CASE 
WHEN age<=20 THEN '20岁以下'
WHEN age>20 AND age<=30 THEN '21-30岁'
WHEN age>30 AND age<=40 THEN '31-40岁'
WHEN age>40 AND age<=50 THEN '41-50岁'
WHEN age>50 AND age<=60 THEN '51-60岁'
WHEN age>60  THEN '60岁以上'
END AS 年龄段,
COUNT(*)AS 数量 FROM shopping_trends
GROUP BY 年龄段 ORDER BY 年龄段;

# 4.1.2 性别比列
SELECT gender ,
COUNT(*) AS cnt ,
CONCAT(ROUND(COUNT(*)/SUM(COUNT(*))OVER ()*100,1),'%') ratio 
FROM shopping_trends 
GROUP BY gender;

# 4.1.3 地域集中度
SELECT location,
COUNT(*) AS 客户数,
SUM(purchase_amount ) AS 总消费金额,
ROUND(AVG(purchase_amount),1) AS 平均消费
FROM shopping_trends
GROUP BY location
ORDER BY 客户数 DESC LIMIT 10;
/*
4.1.4 小结
①除了20岁以下的用户较少外，年龄分布均衡，男性用户整体多于女性，
且平均消费水平均在60$左右。因此，产品的广告文案、视觉风格可偏向中性、成熟、稳重，
避免仅针对年轻人的潮流表达。
②Montan地区客户数最多，Alaska地区平均消费金额最高，各地区可分析当地用户画像，及时调整产品品类结构与促销策略。
*/

# 4.2 商品销售分析

# 4.2.1 畅销商品类别分析
SELECT category  ,
COUNT(*) 数量,
SUM(purchase_amount) 总销售额
FROM shopping_trends 
GROUP BY category 
ORDER BY 数量 DESC;

# 4.2.2 商品颜色偏好分析
SELECT color ,
COUNT(*) 数量,
SUM(purchase_amount) 总销售,
ROUND(AVG(purchase_amount),1) 平均销售额
FROM shopping_trends 
GROUP BY color
ORDER BY 数量 DESC LIMIT 10;

# 4.2.3 季节性销售趋势分析
SELECT season,
COUNT(*) 数量,
SUM(purchase_amount) 总销售额,
ROUND(AVG(purchase_amount),1) 平均销售额
FROM shopping_trends 
GROUP BY season ORDER BY 数量 DESC;

/* 4.2.4 小结
①Clothing是最畅销的商品类别，且总销售额最高。因此可将Clothing作为主打品类，加大款式更新与库存保障，并围绕其开发搭配商品（如Accessories）或推出季节限定系列。

② 颜色偏好方面，Olive色系的客户选择最多，Green色系的平均销售额最高。可在商品设计、广告视觉中优先采用这些流行色，并在商品详情页强化颜色筛选与推荐。

③季节性销售趋势显示，秋季的销售最为活跃，且不同季节的热销品类与颜色存在差异。可根据季节特点调整主推品类与主推色系，在旺季加大促销力度，在淡季可通过折扣或捆绑销售清理库存。
*/

# 4.3 用户购买行为特征分析

# 4.3.1 支付方式偏好方式
SELECT payment_method,
COUNT(*) 数量,
CONCAT(ROUND(COUNT(*)/SUM(COUNT(*))OVER()*100,2),'%') 占比
FROM shopping_trends
GROUP BY payment_method
ORDER BY 数量 DESC;

# 4.3.2 配送方式偏好分析
SELECT shipping_type,
COUNT(*) 数量,
CONCAT (ROUND(COUNT(*)/SUM(COUNT(*))OVER()*100,2),'%') 占比,
ROUND(AVG(purchase_amount),1) 平均金额
FROM shopping_trends
GROUP BY shipping_type 
ORDER BY 数量 DESC;

# 4.3.3 优惠活动效果分析
/*
在创建’优惠组合字段’探究优惠码与折扣的叠加效果后，
发现客户要么两者都使用，要么都不使用，并没有仅折扣或仅优惠码的情况，
这可能与商家的促销活动有关，因此选择折扣这一指标探究优惠活动效果。
*/

/*
4.3.4 小结
① PayPal、Credit Card、Cash是用户常用的支付方式，Free Shipping配送方式使用频率最高。可以优化支付方式的支付体验、同时调整运费策略，提升支付以及配送的服务质量，以提高用户满意度。

②使用优惠的比没有使用优惠的平均消费金额低0.85，优惠的使用在不同品类、支付方式、购买频率上分布较为均匀，但与订阅状态存在强关联。这也说明了优惠活动可能主要面向订阅用户，且折扣与优惠码绑定使用，缺乏灵活的选择空间。建议简化优惠规则，根据用户的不同偏好，设计更好的营销活动。
*/

# 4.4 高复购客户分析

# 4.4.1 历史购买次数分析
SELECT 
    CASE 
        WHEN previous_purchases = 1 THEN '1次购买'
        WHEN previous_purchases BETWEEN 2 AND 5 THEN '2-5次购买'
        WHEN previous_purchases BETWEEN 6 AND 10 THEN '6-10次购买'
        WHEN previous_purchases > 10 THEN '10+次购买'
    END AS 购买次数,
    COUNT(*) AS 客户数量,
    CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2), '%') AS 占比
FROM shopping_trends
GROUP BY 
    CASE 
        WHEN previous_purchases = 1 THEN '1次购买'
        WHEN previous_purchases BETWEEN 2 AND 5 THEN '2-5次购买'
        WHEN previous_purchases BETWEEN 6 AND 10 THEN '6-10次购买'
        WHEN previous_purchases > 10 THEN '10+次购买'
    END
ORDER BY 客户数量 DESC;

#4.4.2 购买频率分析
 WITH t1 AS (
    SELECT 
        frequency_of_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN '1次购买'
            WHEN previous_purchases BETWEEN 2 AND 5 THEN '2-5次购买'
            WHEN previous_purchases BETWEEN 6 AND 10 THEN '6-10次购买'
            WHEN previous_purchases > 10 THEN '10+次购买'
        END AS 购买次数,
        COUNT(*) AS 客户数量
    FROM shopping_trends
    GROUP BY 
        frequency_of_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN '1次购买'
            WHEN previous_purchases BETWEEN 2 AND 5 THEN '2-5次购买'
            WHEN previous_purchases BETWEEN 6 AND 10 THEN '6-10次购买'
            WHEN previous_purchases > 10 THEN '10+次购买'
        END
)
SELECT 
    frequency_of_purchases AS 购买频率,
    SUM(CASE WHEN 购买次数 = '1次购买' THEN 客户数量 ELSE 0 END) AS `1次购买次数`,
    SUM(CASE WHEN 购买次数 = '2-5次购买' THEN 客户数量 ELSE 0 END) AS `2-5次购买次数`,
    SUM(CASE WHEN 购买次数 = '6-10次购买' THEN 客户数量 ELSE 0 END) AS `6-10次购买次数`,
    SUM(CASE WHEN 购买次数 = '10+次购买' THEN 客户数量 ELSE 0 END) AS `10+次购买次数`,
    SUM(客户数量) AS 总客户数
FROM t1 
GROUP BY frequency_of_purchases
ORDER BY frequency_of_purchases;

# 4.4.3 高复购用户的特征
SELECT
    COUNT(
        CASE 
            WHEN previous_purchases > 5
                 AND frequency_of_purchases IN ('Bi-Weekly', 'Weekly', 'Fortnightly')
            THEN customer_id 
            ELSE NULL 
        END
    ) AS 高复购人数,
    
    CONCAT(
        ROUND(

            COUNT(
                CASE 
                    WHEN previous_purchases > 5
                         AND frequency_of_purchases IN ('Bi-Weekly', 'Weekly', 'Fortnightly')
                    THEN customer_id 
                    ELSE NULL 
                END
            ) * 100.0 / COUNT(*), 
            2
        ), 
        '%'
    ) AS 占比
FROM shopping_trends; 
 
 # 4.4.4 小结
 /*
高复购用户占总用户数的37%，虽然高复购用户在商品类别的选择上差异不大，
但在颜色、支付方式、配送方式上均有差异。
建议针对高复购用户设计专属权益（如会员等级、专属折扣），提升其粘性；同时通过推送高频品类、订阅服务等方式，引导中低频用户向高复购转化。
 */
 
 # 4.5 忠诚度分析

# 第一步：对各个指标赋值
WITH T1 AS (
SELECT
    Previous_Purchases,
    CASE
        WHEN Frequency_of_Purchases = 'Bi-Weekly' THEN 7
        WHEN Frequency_of_Purchases = 'Weekly' THEN 6
        WHEN Frequency_of_Purchases = 'Fortnightly' THEN 5
        WHEN Frequency_of_Purchases = 'Monthly' THEN 4
        WHEN Frequency_of_Purchases = 'Every 3 Months' THEN 3
        WHEN Frequency_of_Purchases = 'Quarterly' THEN 2
        WHEN Frequency_of_Purchases = 'Annually' THEN 1
    END Frequency_of_Purchases,
    CASE
        WHEN Purchase_Amount < AVG(Purchase_Amount)OVER(PARTITION BY Category) * 0.8 THEN 1
        WHEN Purchase_Amount BETWEEN AVG(Purchase_Amount)OVER(PARTITION BY Category) * 0.8
            AND AVG(Purchase_Amount)OVER(PARTITION BY Category) * 1.2 THEN 2
        WHEN Purchase_Amount > AVG(Purchase_Amount)OVER(PARTITION BY Category) * 1.2 THEN 3
    END Purchase_Amount,
    IF(Discount_Applied='Yes', 0, 1) Discount_Applied,
    Review_Rating,
    IF(Subscription_Status='Yes', 1, 0) Subscription_Status
FROM
    shopping_trends
),

# 第二步：对每个指标进行Min-Max归一化，使其得分范围统一映射到0-100之间

T2 AS (
SELECT
    (Previous_Purchases - MIN(Previous_Purchases)OVER())/(MAX(Previous_Purchases)OVER() - MIN(Previous_Purchases)OVER())*100 X1,
    (Frequency_of_Purchases - MIN(Frequency_of_Purchases)OVER())/(MAX(Frequency_of_Purchases)OVER() - MIN(Frequency_of_Purchases)OVER())*100 X2,
    (Purchase_Amount - MIN(Purchase_Amount)OVER())/(MAX(Purchase_Amount)OVER() - MIN(Purchase_Amount)OVER())*100 X3,
    (Discount_Applied - MIN(Discount_Applied)OVER())/(MAX(Discount_Applied)OVER() - MIN(Discount_Applied)OVER())*100 X4,
    (Review_Rating - MIN(Review_Rating)OVER())/(MAX(Review_Rating)OVER() - MIN(Review_Rating)OVER())*100 X5,
    (Subscription_Status - MIN(Subscription_Status)OVER())/(MAX(Subscription_Status)OVER() - MIN(Subscription_Status)OVER())*100 X6
FROM T1
)

# 第三步：赋权得到忠诚度指数，进而划分为五个等级，
# 0-20忠诚度极低、20-40忠诚度低、40-60忠诚度中等、60-80忠诚度高、80-100忠诚度极高。

SELECT
    CASE WHEN 忠诚度指数 < 20 THEN '忠诚度极低'
    WHEN 忠诚度指数 >= 20 AND 忠诚度指数 < 40 THEN '忠诚度低'
    WHEN 忠诚度指数 >= 40 AND 忠诚度指数 < 60 THEN '忠诚度中等'
    WHEN 忠诚度指数 >= 60 AND 忠诚度指数 < 80 THEN '忠诚度高'
    WHEN 忠诚度指数 >=80 THEN '忠诚度极高'
    END 忠诚度,
    COUNT(*) 客户数量
FROM (
    SELECT
        X1 * 0.25 + X2 * 0.2 + X3 * 0.2 + X4 * 0.05 + X5 * 0.15 + X6 * 0.15 忠诚度指数
    FROM T2
) T3
GROUP BY 忠诚度
ORDER BY FIELD(忠诚度 , '忠诚度极低' , '忠诚度低' , '忠诚度中等' , '忠诚度高' , '忠诚度极高')

/*4.6 小结
①忠诚度极低（0-20分）为沉睡用户，占比3.1%，他们可能只是尝试性购买，对品牌几乎没有粘性，复购概率极低。

营销策略：暂不投入高成本，可通过推送大额优惠券或爆款推荐，尝试激活；若长期无反应，可考虑放弃。

②忠诚度低（20-40分）为低频用户，占比30.7%，这些用户对价格敏感，品牌忠诚度尚未形成，容易被竞品吸引，但仍有转化潜力。

营销策略：推送组合折扣、满减活动，鼓励提高客单价；推荐高频品类培养购买习惯；尝试引导订阅会员获取权益。

③忠诚度中等（40-60分）为普通活跃用户，占比47.2%，这些用户已形成一定购买习惯，对品牌有基本信任，是维持销售额的中坚力量。

营销策略：保持关系维护，提供更多基础权益，如积分兑换、满额包邮等，鼓励向高忠诚度升级。

④忠诚度高（60-80分）为忠诚粉丝，占比17.9%，大都是品牌的核心用户，复购稳定，愿意为品质支付溢价，且可能自发传播。

营销策略：提供专属会员等级、生日礼遇、优先购、专属客服等VIP服务；邀请参与新品内测或品牌活动，增强归属感与口碑。

⑤忠诚度极高（80-100分）为超级用户，占比1.1%，是品牌的最有价值用户，贡献度高，是口碑传播的核心力量，可能成为品牌大使。

营销策略：建立一对一维护机制，提供定制化服务、限量款优先权、年度答谢礼；鼓励其分享推荐，给予推荐奖励或联名机会。
*/

/*五 总结
1 用户画像：各个年龄段分布还算均匀，男性用户略多，平均消费差别不大。Montana客户最多，Alaska人均消费最高。稳重、中性风格的广告和产品设计更能覆盖主流人群。不同地区的消费力有高有低，后续可以针对性地调整品类和促销策略。

2 商品销售：Clothing是绝对主力，销量和销售额都排第一，颜色上Olive最受欢迎，Green虽然量不大但客单价高。秋季销量高，不同季节热销品类和颜色也有变化。后续可以主推Clothing，根据季节调整主色调和品类，旺季加大力度，淡季清库存。

3 购买行为：支付方式上PayPal、信用卡、现金排前三，免邮配送最受欢迎。使用优惠的客户平均消费比未使用优惠的低，且优惠和订阅强相关，几乎都是捆绑使用。说明现在的优惠规则比较死板，可以加以优化，给不同用户更灵活的选择。

4 高复购客户：占总用户37%，这部分人在颜色、支付、配送上跟普通用户不太一样，但品类偏好差别不大。可以对其试用会员权益、专属折扣等，稳住基本盘，另外可以通过推荐高频品类、引导订阅等拉动中低频客户。

5 忠诚度分层：从行为、态度、关系三个角度打分，把客户分成五个层级。极低忠诚的沉睡用户不用强留，低忠诚的可试用优惠激活，中等忠诚的关系维持好，高忠诚度与超级用户群体，应构建专属维护体系，通过VIP服务、定制化权益及推荐激励机制，提升其归属感与品牌认同，引导其成为品牌的自发传播者。
