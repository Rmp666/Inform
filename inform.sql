-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Фев 11 2019 г., 18:29
-- Версия сервера: 5.6.41
-- Версия PHP: 7.0.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `inform`
--

DELIMITER $$
--
-- Функции
--
CREATE DEFINER=`root`@`%` FUNCTION `calc_total_weight` (`items_id` INT, `order_id` INT) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
DECLARE mark_steel VARCHAR(50);
DECLARE code_type VARCHAR(50);
DECLARE type_steel VARCHAR(45);
DECLARE width INT;
DECLARE length INT;
DECLARE height INT;
DECLARE weight_steel DECIMAL(5,2);
DECLARE cnt_constr INT;
DECLARE answer VARCHAR(200);
DECLARE is_error BOOL DEFAULT 0;
DECLARE total_weight_loc DOUBLE DEFAULT -1;
 
-- данные 
SELECT o.type_prod, o.mark_steel, o.width_d, o.length, o.height, s.specific_weight_steel FROM order_items o
JOIN steels s ON (s.mark_steel = o.mark_steel)
WHERE (o.num_items = items_id) AND (o.num_ord = order_id)
INTO type_steel, mark_steel, width, length, height, weight_steel;
-- валидация
 


	SELECT count(*) FROM constraint_type c 
	JOIN prod_type p ON (p.id_type = c.id_type)
	WHERE p.code_type = type_steel and (
		( (length between min_constr and max_constr)  and code_constr = 'L')
		or
		( (width between min_constr and max_constr)  and code_constr = 'D')
		or
		( (height between min_constr and max_constr ) and code_constr = 'H')
	) INTO cnt_constr;
-- итоговый вес по пункту    
IF type_steel = 'square'
THEN
	IF cnt_constr = 3 
    THEN
		 set total_weight_loc = (height*width*length*weight_steel)/1000; -- кг
	ELSE
		set is_error = 1;
	END IF;
END IF;
IF type_steel = 'round'
THEN
	IF cnt_constr = 2 
    THEN
		 set total_weight_loc = (weight_steel*width*length*pi())/1000; -- кг
	ELSE
		set is_error = 1;
	END IF;
END IF;

IF total_weight_loc <> -1  THEN
	UPDATE order_items set total_weight = total_weight_loc where  num_items = items_id and num_ord = order_id;
END IF; 
 
IF is_error != 1 
	THEN
		set answer = '';
    ELSE 
		set answer = 
        (
			SELECT GROUP_CONCAT(name_constr)  FROM constraint_type c 
			JOIN prod_type p ON (p.id_type = c.id_type)
			WHERE p.code_type = type_steel
		);
END IF;  

RETURN  answer; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `constraint_type`
--

CREATE TABLE `constraint_type` (
  `id_constr` int(11) NOT NULL,
  `id_type` int(11) DEFAULT NULL,
  `name_constr` varchar(45) NOT NULL,
  `code_constr` varchar(45) DEFAULT NULL,
  `min_constr` int(11) DEFAULT NULL,
  `max_constr` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `constraint_type`
--

INSERT INTO `constraint_type` (`id_constr`, `id_type`, `name_constr`, `code_constr`, `min_constr`, `max_constr`) VALUES
(1, 1, 'Диаметр', 'D', 5, 30),
(2, 1, 'Длина', 'L', 20, 300),
(3, 2, 'Ширина', 'D', 5, 70),
(4, 2, 'Высота', 'H', 5, 30),
(5, 2, 'Длина', 'L', 20, 300);

-- --------------------------------------------------------

--
-- Структура таблицы `customers`
--

CREATE TABLE `customers` (
  `cust_id` int(11) NOT NULL,
  `cust_name` varchar(45) NOT NULL,
  `address` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `customers`
--

INSERT INTO `customers` (`cust_id`, `cust_name`, `address`) VALUES
(1, 'customers1', 'address1'),
(2, 'customers2', 'address2'),
(3, 'customers3', 'address3'),
(4, 'customers4', 'address4');

-- --------------------------------------------------------

--
-- Структура таблицы `orders`
--

CREATE TABLE `orders` (
  `num_ord` int(11) NOT NULL,
  `date_ord` datetime DEFAULT CURRENT_TIMESTAMP,
  `cust_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- --------------------------------------------------------

--
-- Структура таблицы `order_items`
--

CREATE TABLE `order_items` (
  `num_items` int(11) NOT NULL,
  `num_ord` int(11) NOT NULL,
  `type_prod` varchar(50) NOT NULL,
  `mark_steel` varchar(50) NOT NULL,
  `width_d` int(11) NOT NULL,
  `height` int(11) DEFAULT NULL,
  `length` int(11) NOT NULL,
  `total_weight` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `prod_constraint_v`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `prod_constraint_v` (
`name_type` varchar(45)
,`code_type` varchar(45)
,`id_constr` int(11)
,`id_type` int(11)
,`name_constr` varchar(45)
,`code_constr` varchar(45)
,`min_constr` int(11)
,`max_constr` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `prod_type`
--

CREATE TABLE `prod_type` (
  `id_type` int(11) NOT NULL,
  `name_type` varchar(45) NOT NULL,
  `code_type` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `prod_type`
--

INSERT INTO `prod_type` (`id_type`, `name_type`, `code_type`) VALUES
(1, 'Круглое сечение', 'round'),
(2, 'Прямоугольное сечение', 'square');

-- --------------------------------------------------------

--
-- Структура таблицы `steels`
--

CREATE TABLE `steels` (
  `mark_steel` varchar(50) NOT NULL,
  `type_steel` varchar(45) NOT NULL,
  `specific_weight_steel` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `steels`
--

INSERT INTO `steels` (`mark_steel`, `type_steel`, `specific_weight_steel`) VALUES
('09Г2С', 'низколегированная конструкционная', '7.85'),
('10А', 'сталь малоуглеродистая', '7.85'),
('20', 'качественная конструкционная углеродистая', '7.85'),
('30ХГСА', 'легированная конструкционная', '7.85'),
('45', 'сталь среднеуглеродистая', '7.85'),
('5ХНМ', 'штамповая инструментальная', '7.80'),
('65Г', 'ресссорно-пружинная конструкционная', '7.85'),
('70', 'сталь высокоуглеродистая', '7.85'),
('СТ3СП', 'углеродистая конструкционная', '7.87'),
('Х12МФ', 'штамповая инструментальная', '7.70');

-- --------------------------------------------------------

--
-- Структура для представления `prod_constraint_v`
--
DROP TABLE IF EXISTS `prod_constraint_v`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `prod_constraint_v`  AS  select `p`.`name_type` AS `name_type`,`p`.`code_type` AS `code_type`,`c`.`id_constr` AS `id_constr`,`c`.`id_type` AS `id_type`,`c`.`name_constr` AS `name_constr`,`c`.`code_constr` AS `code_constr`,`c`.`min_constr` AS `min_constr`,`c`.`max_constr` AS `max_constr` from (`prod_type` `p` join `constraint_type` `c` on((`p`.`id_type` = `c`.`id_type`))) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `constraint_type`
--
ALTER TABLE `constraint_type`
  ADD PRIMARY KEY (`id_constr`),
  ADD KEY `id_type_idx` (`id_type`);

--
-- Индексы таблицы `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`cust_id`);

--
-- Индексы таблицы `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`num_ord`),
  ADD UNIQUE KEY `num_ord_UNIQUE` (`num_ord`),
  ADD KEY `cust_id` (`cust_id`);

--
-- Индексы таблицы `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`num_items`,`num_ord`),
  ADD KEY `num_ord_idx` (`num_ord`);

--
-- Индексы таблицы `prod_type`
--
ALTER TABLE `prod_type`
  ADD PRIMARY KEY (`id_type`),
  ADD UNIQUE KEY `code_type_UNIQUE` (`code_type`);

--
-- Индексы таблицы `steels`
--
ALTER TABLE `steels`
  ADD PRIMARY KEY (`mark_steel`),
  ADD UNIQUE KEY `mark_steel_UNIQUE` (`mark_steel`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `constraint_type`
--
ALTER TABLE `constraint_type`
  MODIFY `id_constr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `customers`
--
ALTER TABLE `customers`
  MODIFY `cust_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `orders`
--
ALTER TABLE `orders`
  MODIFY `num_ord` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT для таблицы `prod_type`
--
ALTER TABLE `prod_type`
  MODIFY `id_type` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `constraint_type`
--
ALTER TABLE `constraint_type`
  ADD CONSTRAINT `id_type` FOREIGN KEY (`id_type`) REFERENCES `prod_type` (`id_type`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Ограничения внешнего ключа таблицы `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`cust_id`) REFERENCES `customers` (`cust_id`);

--
-- Ограничения внешнего ключа таблицы `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `num_ord` FOREIGN KEY (`num_ord`) REFERENCES `orders` (`num_ord`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
