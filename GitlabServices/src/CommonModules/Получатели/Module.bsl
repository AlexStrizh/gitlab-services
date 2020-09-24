#Область ПрограммныйИнтерфейс

// Отправка файла в информационную базу получателя. Адрес подключения определяется из параметра доставки.
// На конечных точках (базах получателях) должен быть реализован API обновления внешних отчетов и обработок:
// https://app.swaggerhub.com/apis-docs/astrizhachuk/gitlab-services-receiver/1.0.0
// 
// Параметры:
// 	ИмяФайла - Строка - имя файла, по которому производится поиск и замена внешних отчетов и обработок (UTF-8);
// 	Данные - ДвоичныеДанные - тело файла в двоичном формате;
// 	ПараметрыДоставки - Структура - параметры доставки файла:
// * Адрес - Строка - адрес веб-сервиса для работы с внешними отчетами и обработками в информационной базе получателе;
// * Token - Строка - token доступа к сервису получателя;
// * Таймаут - Число - таймаут соединения с сервисом, секунд (если 0 - таймаут не установлен);
// 	ПараметрыСобытия - Неопределено, Структура - описание события, запустившее отправку файла:
// * ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// * CheckoutSHA - Строка - уникальный идентификатор события (commit SHA), для которого запускается отправка файла;
//
Процедура ОтправитьФайл( Знач ИмяФайла, Знач Данные, Знач ПараметрыДоставки, ПараметрыСобытия = Неопределено ) Экспорт
	
	Перем Заголовки;
	Перем ПараметрыЗапроса;
	Перем Ответ;
	Перем КодСостояния;
	Перем Сообщение;
	
	Ответ = Неопределено;
	
	Попытка
		
		ОтправитьФайлПроверкаВходящихПараметров( ИмяФайла, Данные, ПараметрыДоставки );
		
		Заголовки = Новый Соответствие();
		Заголовки.Вставить( "Token", ПараметрыДоставки.Token );
		Заголовки.Вставить( "Name", КодироватьСтроку(ИмяФайла, СпособКодированияСтроки.URLВКодировкеURL) );
		
		ПараметрыЗапроса = Новый Структура();
		ПараметрыЗапроса.Вставить( "Заголовки", Заголовки );
		ПараметрыЗапроса.Вставить( "Таймаут", ПараметрыДоставки.Таймаут );
		
		Ответ = КоннекторHTTP.Post( ПараметрыДоставки.Адрес, Данные, ПараметрыЗапроса );
		
		Сообщение = СформироватьСообщение( Ответ, ИмяФайла, ПараметрыДоставки );
	
		Если ( НЕ КодыСостоянияHTTPКлиентСерверПовтИсп.isOk(Ответ.КодСостояния) ) Тогда
			
			ВызватьИсключение Сообщение;
			
		КонецЕсли;
		
		ВыполнитьЛогированиеСообщения( Сообщение, ПараметрыСобытия, Ответ.КодСостояния );
		
	Исключение
		
		КодСостояния = ?( Ответ = Неопределено,
			КодыСостоянияHTTPКлиентСерверПовтИсп.НайтиКодПоИдентификатору("INTERNAL_SERVER_ERROR"),
			Ответ.КодСостояния );
			
		Сообщение = ИнформацияОбОшибке().Описание;
		
		ВыполнитьЛогированиеСообщения( Сообщение, ПараметрыСобытия, КодСостояния );
		
		ВызватьИсключение Сообщение;
		
	КонецПопытки;
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОтправитьФайлПроверкаВходящихПараметров( Знач ИмяФайла, Знач Данные, Знач ПараметрыДоставки )
	
	Перем СтруктураПараметров;

	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр( "Получатели.ОтправитьФайл",
													"ИмяФайла",
													ИмяФайла,
													Тип("Строка") );
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(	"Получатели.ОтправитьФайл",
													"Данные",
													Данные,
													Тип("ДвоичныеДанные") );
	
	СтруктураПараметров = Новый Структура( "Адрес, Token", Тип("Строка"), Тип("Строка") );
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр( "Получатели.ОтправитьФайл",
													"ПараметрыДоставки",
													ПараметрыДоставки,
													Тип("Структура"),
													СтруктураПараметров );

КонецПроцедуры

Процедура ВыполнитьЛогированиеСообщения( Сообщение, Знач ПараметрыСобытия, Знач КодСостояния )
	
	Перем ПараметрыЛогирования;
	
	ПараметрыЛогирования = Неопределено;
	
	Если ( ПараметрыСобытия <> Неопределено ) Тогда
		
		ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ПараметрыСобытия.ОбработчикСобытия );
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( Сообщение, ПараметрыСобытия.CheckoutSHA );
		
	КонецЕсли;

	Если ( КодыСостоянияHTTPКлиентСерверПовтИсп.isOk(КодСостояния) ) Тогда
		
		Логирование.Информация( "Core.ОтправкаДанныхПолучателю", Сообщение, ПараметрыЛогирования );

	Иначе
		
		Логирование.Ошибка( "Core.ОтправкаДанныхПолучателю", Сообщение, ПараметрыЛогирования );
		
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьСообщение( Знач Ответ, Знач ИмяФайла, Знач ПараметрыДоставки )
	
	Перем ТекстОтвета;
	Перем Результат;
	
	Результат = НСтр( "ru = 'адрес доставки: %1; файл: %2'" );
	Результат = СтрШаблон( Результат, ПараметрыДоставки.Адрес, ИмяФайла );
	
	Если ( КодыСостоянияHTTPКлиентСерверПовтИсп.isOk(Ответ.КодСостояния) ) Тогда
		
		ТекстОтвета = КоннекторHTTP.КакТекст(Ответ, КодировкаТекста.UTF8);
		
	Иначе
		
		ТекстОтвета = "[ Error ]: Response Code: " + Ответ.КодСостояния;
		
	КонецЕсли;
	
	Возврат Результат + "; сообщение:" + Символы.ПС + ТекстОтвета;
	
КонецФункции

#КонецОбласти