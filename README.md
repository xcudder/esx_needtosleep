# esx_needtosleep
Adding an esx_status based need to sleep based on the 48 minutes - 24 in game hours paradigm.

Requires esx_status and esx_basicneeds.

And the following SQL:
```
INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('junkfood', 'Junk Food', 1),
	('sugarydrink', 'Sugary Drink', 1),
	('coffee', 'Coffee', 1)
;
```
inside esx_needtosleep.sql