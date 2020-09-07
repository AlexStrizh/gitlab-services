#Область СлужебныйПрограммныйИнтерфейс


// Добавляет описание файлов с настройками маршрутизации в коллекцию файлов для последующего их скачивания. 
// 
// Параметры:
// 	ОписаниеФайлов - ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// 	ДанныеЗапроса - Соответствие - преобразованное в коллекцию тело запроса;
// 	ПараметрыПроекта - Структура - описание:
// * Идентификатор - Строка - числовой идентификатор проекта (репозитория);
// * АдресСервера - Строка - адрес сервера вместе со схемой обращения к серверу;
//
Процедура СформироватьОписаниеФайловМаршрутизации( ОписаниеФайлов, Знач ДанныеЗапроса, Знач ПараметрыПроекта ) Экспорт
	
	Перем ПолноеИмяФайла;
	Перем Commits;
	Перем CommitSHA;
	Перем ПутьКФайлуRAW;
	Перем НоваяСтрока;

	Commits = ДанныеЗапроса.Получить( "commits" );	
	ПолноеИмяФайла = НастройкаСервисов.ТекущиеНастройки().ИмяФайлаНастроекМаршрутизации;
	
	Для каждого Commit Из Commits Цикл

		НоваяСтрока = ОписаниеФайлов.Добавить();
		CommitSHA = Commit.Получить( "id" );
		ПутьКФайлуRAW = Gitlab.ПутьКФайлуRAW( ПараметрыПроекта.Идентификатор, ПолноеИмяФайла, CommitSHA );
		НоваяСтрока.ПутьКФайлуRAW = ПутьКФайлуRAW;
		НоваяСтрока.ПолноеИмяФайла = ПолноеИмяФайла;
		НоваяСтрока.Операция = "";
		НоваяСтрока.Дата = Commit.Получить( "timestamp" );
		НоваяСтрока.CommitSHA = CommitSHA;
	
	КонецЦикла;

КонецПроцедуры


// Добавляет JSON настройки маршрутизации файлов в данные запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - преобразованное в коллекцию тело запроса;
// 	ДанныеДляОтправки - ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
//
Процедура ДополнитьЗапросНастройкамиМаршрутизацииJSON( ДанныеЗапроса, Знач ДанныеДляОтправки ) Экспорт
	
	Перем ПолноеИмяФайла;
	Перем Commits;
	Перем ПараметрыОтбора;
	Перем НайденныеНастройки;
	Перем JSON;

	ПолноеИмяФайла = НастройкаСервисов.ТекущиеНастройки().ИмяФайлаНастроекМаршрутизации;	
	Commits = ДанныеЗапроса.Получить( "commits" );
	
	Для каждого Commit Из Commits Цикл
		
		ПараметрыОтбора = Новый Структура();
		ПараметрыОтбора.Вставить( "CommitSHA", Commit.Получить( "id" ) );
		ПараметрыОтбора.Вставить( "ПолноеИмяФайла", ПолноеИмяФайла );
		ПараметрыОтбора.Вставить( "Операция", "" );
		ПараметрыОтбора.Вставить( "ОписаниеОшибки", "" );
		
		НайденныеНастройки = ДанныеДляОтправки.НайтиСтроки( ПараметрыОтбора );
		
		Если ( НЕ ЗначениеЗаполнено(НайденныеНастройки) ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		JSON = ПолучитьСтрокуИзДвоичныхДанных( НайденныеНастройки[0].ДвоичныеДанные,  КодировкаТекста.UTF8 );
		Commit.Вставить( "settings", JSON );
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти