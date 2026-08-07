-- Sample data (safe to re-run: cleared first)
TRUNCATE favorites, routes, hotels, restaurants, attractions, cities RESTART IDENTITY CASCADE;

INSERT INTO cities (name, region, description, latitude, longitude) VALUES
 ('თბილისი',  'ქართლი',   'საქართველოს დედაქალაქი მდინარე მტკვრის ნაპირზე.', 41.7151, 44.8271),
 ('ბათუმი',   'აჭარა',    'შავი ზღვის სანაპირო ქალაქი, საკურორტო ცენტრი.',    41.6168, 41.6367),
 ('ქუთაისი',  'იმერეთი',  'დასავლეთ საქართველოს ისტორიული ქალაქი.',          42.2679, 42.7180),
 ('მცხეთა',   'მცხეთა',   'უძველესი დედაქალაქი, UNESCO-ს მემკვიდრეობა.',      41.8458, 44.7207);

INSERT INTO attractions (city_id, name, category, description, latitude, longitude) VALUES
 (1, 'ნარიყალა',          'ციხესიმაგრე', 'ძველი ციხე თბილისის თავზე.',      41.6884, 44.8090),
 (1, 'მშვიდობის ხიდი',    'ღირსშესანიშნაობა', 'თანამედროვე ქვეითთა ხიდი.',  41.6928, 44.8089),
 (2, 'ბათუმის ბულვარი',  'პარკი',        'ზღვისპირა სასეირნო ბულვარი.',     41.6470, 41.6360),
 (4, 'სვეტიცხოველი',      'ტაძარი',       'XI საუკუნის საკათედრო ტაძარი.',   41.8419, 44.7222);

INSERT INTO restaurants (city_id, name, cuisine, price_level, address) VALUES
 (1, 'ბარბარესთანი', 'ქართული', 2, 'ძველი თბილისი'),
 (2, 'ღვინის სახლი', 'ქართული', 2, 'ბათუმი, ცენტრი');

INSERT INTO hotels (city_id, name, stars, address) VALUES
 (1, 'Rooms Tbilisi', 4, 'ვერა, თბილისი'),
 (2, 'Sea View',      3, 'ბათუმი, სანაპირო');

INSERT INTO routes (city_id, title, description, duration_hours, difficulty) VALUES
 (1, 'ძველი თბილისის სავალი', 'ნარიყალა, აბანოთუბანი, მშვიდობის ხიდი.', 3, 'მარტივი'),
 (4, 'მცხეთის ერთდღიანი ტური', 'სვეტიცხოველი და ჯვრის მონასტერი.',     4, 'საშუალო');
