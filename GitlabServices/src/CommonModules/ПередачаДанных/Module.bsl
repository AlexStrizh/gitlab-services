#Область ПрограммныйИнтерфейс

// Передает имя и тело файла (двоичные данные) в ИБ-приемник через его веб-сервис. Адрес подключения берется из параметра доставки.
// 
// Параметры:
// 	ИмяФайла - Строка - имя файла, по которому производится поиск и замена внешних отчетов/обработок.
// 	Данные - ДвоичныеДанные - содержимое файла в бинарном формате;
// 	ПараметрыДоставки - (См. ИнициализироватьПараметрыДоставки);
//
Процедура Доставить(Знач ИмяФайла, Знач Данные, Знач ПараметрыДоставки) Экспорт
	
	Перем АдресДоставки;

	Попытка
		
		ДоставитьФайлПроверкаВходящихПараметров(ИмяФайла, Данные, ПараметрыДоставки);
		
		Заголовки  = Новый Соответствие;
		Заголовки.Вставить("Token", ПараметрыДоставки.Token);
		Name = КодироватьСтроку(ИмяФайла, СпособКодированияСтроки.URLВКодировкеURL);
		Заголовки.Вставить("Name", Name);
		
		АдресДоставки = ПараметрыДоставки.ТочкаДоставки;

		ПараметрыЗапроса = Новый Структура("Заголовки, Таймаут", Заголовки, ПараметрыДоставки.Таймаут);
		Ответ = КоннекторHTTP.Post(АдресДоставки,  Данные, ПараметрыЗапроса);
		
		//Ответ.КодСостояния
		
		ТекстОтвета = КоннекторHTTP.КакТекст(Ответ, КодировкаТекста.UTF8);
		
		
		Сообщение = Новый СообщениеПользователю();	
		Шаблон = НСтр("ru = 'Адрес доставки: %1; Файл: %2; Сообщение: %3'");
		Сообщение.Текст = СтрШаблон(Шаблон, АдресДоставки, ИмяФайла, ТекстОтвета);
		Сообщение.Сообщить();								
		
	Исключение

		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			
		Сообщение = Новый СообщениеПользователю();	
		Шаблон = НСтр("ru = 'Адрес доставки: %1; Файл: %2; Сообщение: %3'");
		Сообщение.Текст = СтрШаблон(Шаблон, АдресДоставки, ИмяФайла, ТекстОшибки);
		Сообщение.Сообщить();	
		
		вызватьисключение; //?
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДоставитьФайлПроверкаВходящихПараметров(Знач ИмяФайла, Знач Данные, Знач ПараметрыДоставки)
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"ВнешниеОбработки.Доставить",
		"ИмяФайла",
		ИмяФайла,
		Тип("Строка"));
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"ВнешниеОбработки.Доставить",
		"Данные",
		Данные,
		Тип("ДвоичныеДанные"));
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"ВнешниеОбработки.Доставить",
		"ПараметрыДоставки",
		ПараметрыДоставки,
		Тип("Структура"),
		Новый Структура("ТочкаДоставки, Token", Тип("Строка"), Тип("Строка")));
	
КонецПроцедуры

#КонецОбласти