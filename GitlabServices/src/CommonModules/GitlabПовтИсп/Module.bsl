#Region Internal

// Возвращает пустую коллекцию с описанием файлов. 
// 
// Возвращаемое значение:
// 	ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
//
Функция ОписаниеФайлов() Экспорт

	Var Результат;
	
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить( "ПутьКФайлуRAW", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные") );
	Результат.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "Дата", Новый ОписаниеТипов("Дата") );
	Результат.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка") );

	Возврат Результат;
	
КонецФункции

// Возвращает перечень возможных действий над файлами в соответствии с REST API GitLab.
// 
// Возвращаемое значение:
// 	Массив - "added", "modified", "removed";
//
Функция ПереченьОперацийНадФайлами() Экспорт
	
	Var Результат;
	
	Результат = Новый Массив();
	Результат.Добавить( "added" );
	Результат.Добавить( "modified" );
	Результат.Добавить( "removed" );

	Возврат Результат;
	
КонецФункции

#EndRegion
