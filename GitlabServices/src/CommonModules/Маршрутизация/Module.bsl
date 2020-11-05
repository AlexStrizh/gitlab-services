#Region Internal

// TODO подумать об упрощении
// TODO подумать о возвращении отправки по доступным маршрутам, если файл не имеет описания в json

// Возвращает коллекцию файлов к отправке с адресами доставки.
// 
// Параметры:
// 	ОтправляемыеДанные - ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// Возвращаемое значение:
// 	Массив Из Структура:
// * ИмяФайла - Строка - имя файла; 
// * ДвоичныеДанные - ДвоичныеДанные - тело файла;
// * АдресаДоставки - Массив Из Строка - адреса доставки;
// * ОписаниеОшибки - Строка - текст ошибки при формировании файла к отправке;
//
Функция РаспределитьОтправляемыеДанныеПоМаршрутам( Знач ОтправляемыеДанные, Знач ДанныеЗапроса ) Экспорт
	
	Var МаршрутыОтправкиФайлов;
	Var ОтправляемыйФайл;
	Var CommitSHA;
	Var Результат;
	
	ROUTING_SETTINGS_MISSING_MESSAGE = НСтр( "ru = '%1: отсутствуют настройки маршрутизации.';
										|en = '%1: there are no routing settings.'" );
										
	DELIVERY_ROUTE_MISSING_MESSAGE = НСтр( "ru = '%1: не задан маршрут доставки файла.';
										|en = '%1: file delivery route not specified.'" );
	
	МаршрутыОтправкиФайлов = МаршрутыОтправкиФайловПоДаннымЗапроса( ДанныеЗапроса );
	
	Результат = Новый Массив();
	
	Для Каждого ОписаниеФайла Из ОтправляемыеДанные Цикл
		
		Если ( ЭтоФайлНастроек(ОписаниеФайла) ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ОтправляемыйФайл = ОтправляемыйФайл();
		
		ЗаполнитьЗначенияСвойств( ОтправляемыйФайл, ОписаниеФайла );
		
		Если ( НЕ ПустаяСтрока(ОтправляемыйФайл.ОписаниеОшибки) ) Тогда
			
			Результат.Добавить(ОтправляемыйФайл);
			
			Продолжить;
			
		КонецЕсли;
			
		CommitSHA = МаршрутыОтправкиФайлов.Получить( ОписаниеФайла.CommitSHA );
	
		Если ( CommitSHA = Неопределено ) Тогда
			
			ОтправляемыйФайл.ОписаниеОшибки = СтрШаблон( ROUTING_SETTINGS_MISSING_MESSAGE, ОписаниеФайла.CommitSHA );

		Иначе

			ОтправляемыйФайл.АдресаДоставки = CommitSHA.Получить( ОписаниеФайла.ПолноеИмяФайла );
			
			Если ( ОтправляемыйФайл.АдресаДоставки = Неопределено ) Тогда

				ОтправляемыйФайл.ОписаниеОшибки = СтрШаблон( DELIVERY_ROUTE_MISSING_MESSAGE, ОписаниеФайла.CommitSHA );
				
			КонецЕсли;

		КонецЕсли;
		
		Результат.Добавить( ОтправляемыйФайл );
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

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
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// 	ПараметрыПроекта - Структура - описание:
// * Идентификатор - Строка - числовой идентификатор проекта (репозитория);
// * АдресСервера - Строка - адрес сервера вместе со схемой обращения к серверу;
//
Процедура СформироватьОписаниеФайловМаршрутизации( ОписаниеФайлов, Знач ДанныеЗапроса, Знач ПараметрыПроекта ) Экспорт
	
	Var ПолноеИмяФайла;
	Var Commits;
	Var CommitSHA;
	Var ПутьКФайлуRAW;
	Var НоваяСтрока;

	Commits = ДанныеЗапроса.Получить( "commits" );	
	ПолноеИмяФайла = ServicesSettings.CurrentSettings().RoutingFileName;
	
	Для каждого Commit Из Commits Цикл

		НоваяСтрока = ОписаниеФайлов.Добавить();
		CommitSHA = Commit.Получить( "id" );
		ПутьКФайлуRAW = GitLab.ПутьКФайлуRAW( ПараметрыПроекта.Идентификатор, ПолноеИмяФайла, CommitSHA );
		НоваяСтрока.ПутьКФайлуRAW = ПутьКФайлуRAW;
		НоваяСтрока.ПолноеИмяФайла = ПолноеИмяФайла;
		НоваяСтрока.Операция = "";
		НоваяСтрока.Дата = Commit.Получить( "timestamp" );
		НоваяСтрока.CommitSHA = CommitSHA;
	
	КонецЦикла;

КонецПроцедуры

// Добавляет десериализованные из JSON настройки маршрутизации файлов в данные запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// 	ДанныеДляОтправки - ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
//
Процедура ДополнитьЗапросНастройкамиМаршрутизации( ДанныеЗапроса, Знач ДанныеДляОтправки ) Экспорт
	
	Var ПолноеИмяФайла;
	Var Commits;
	Var ПараметрыОтбора;
	Var НайденныеНастройки;
	Var НастройкиМаршрутизации;

	ПолноеИмяФайла = ServicesSettings.CurrentSettings().RoutingFileName;	
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
		
		Поток = НайденныеНастройки[0].ДвоичныеДанные.ОткрытьПотокДляЧтения();
		НастройкиМаршрутизации = HTTPConnector.JsonВОбъект( Поток );
		CommonUseServerCall.AppendCollectionFromStream( НастройкиМаршрутизации, "json", Поток );
		
		Commit.Вставить( "settings", НастройкиМаршрутизации );
		
	КонецЦикла;
	
КонецПроцедуры
 
#EndRegion

#Region Private

// Возвращает описание отправляемого файла.
// 
// Возвращаемое значение:
// 	Структура - Описание:
// * ИмяФайла - Строка - имя файла; 
// * ДвоичныеДанные - ДвоичныеДанные - тело файла;
// * АдресаДоставки - Массив Из Строка - адреса доставки;
// * ОписаниеОшибки - Строка - текст ошибки при формировании файла к отправке;
//
Функция ОтправляемыйФайл()
	
	Var Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "ИмяФайла", "" );
	Результат.Вставить( "АдресаДоставки", Неопределено );
	Результат.Вставить( "ДвоичныеДанные", Неопределено );
	Результат.Вставить( "ОписаниеОшибки", "" );
	
	Возврат Результат;
	
КонецФункции

Функция ЭтоФайлНастроек( Знач ОписаниеФайла )
	
	Возврат ПустаяСтрока( ОписаниеФайла.Операция );
	
КонецФункции

// Формирует перечень доступных получателей файлов с адресами веб-сервисов по данным настроек маршрутизации.
// 
// Параметры:
// 	НастройкиМаршрутизации - Соответствие - настройки маршрутизации;
// 	  
// Возвращаемое значение:
// 	Соответствие - доступные сервисы доставки:
//	* Ключ - Строка - имя сервиса;
//	* Значение - Строка - адрес сервиса;
//
Функция ДоступныеСервисыДоставки( Знач НастройкиМаршрутизации )
	
	Var Результат;
	Var СервисыДоставки;
	Var ИмяСервиса;
	Var СервисВключен;
	Var Адрес;
	
	Результат = Новый Соответствие();
	
	СервисыДоставки = НастройкиМаршрутизации.Получить( "ws" );
	
	Если ( СервисыДоставки = Неопределено ) Тогда
		
		Возврат Результат;
		
	КонецЕсли;
	
	Для каждого Сервис Из СервисыДоставки Цикл
		
		ИмяСервиса = Сервис.Получить( "name" );
		
		Если ( ИмяСервиса = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		СервисВключен = Сервис.Получить( "enabled" );
		
		Если ( СервисВключен = Неопределено ИЛИ НЕ СервисВключен ) Тогда
			
			Продолжить;
			
		КонецЕсли;
			
		Адрес = Сервис.Получить( "address" );
		
		Если ( Адрес = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Результат.Вставить( ИмяСервиса, Адрес );

	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция АдресаДоставкиПоПравиламИсключения( Знач СервисыДоставки, Знач ИсключаемыеСервисы )
	
	Var Результат;
	
	Результат = Новый Массив();
	
	Для Каждого Элемент Из СервисыДоставки Цикл
		
		Если ( ИсключаемыеСервисы = Неопределено ИЛИ ИсключаемыеСервисы.Найти(Элемент.Ключ) = Неопределено ) Тогда
	
			Результат.Добавить( Элемент.Значение );
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает адреса доставки файлов по данным настройки маршрутизации.
// 
// Параметры:
// 	НастройкиМаршрутизации - Соответствие - преобразованные в коллекцию настройки маршрутизации;
// 	
// Возвращаемое значение:
// 	Соответствие - описание:
// 	*Ключ - Строка - полное имя файла;
// 	*Значение - Массив из Строка - перечень адресов доставки файла;
//
Функция АдресаДоставкиФайлов( Знач НастройкиМаршрутизации )
	
	Var СервисыДоставки;
	Var ПолноеИмяФайла;
	Var ИсключаемыеСервисы;
	Var АдресаДоставки;
	Var Результат;
	
	СервисыДоставки = ДоступныеСервисыДоставки( НастройкиМаршрутизации );
	
	ПравилаДоставки = НастройкиМаршрутизации.Получить( "epf" );
	
	Результат = Новый Соответствие();
	
	Для каждого Правило Из ПравилаДоставки Цикл
		
		ПолноеИмяФайла = Правило.Получить( "name" );
		
		Если ( ПолноеИмяФайла = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ИсключаемыеСервисы = Правило.Получить( "exclude" );
		АдресаДоставки = АдресаДоставкиПоПравиламИсключения( СервисыДоставки, ИсключаемыеСервисы );

		Результат.Вставить( ПолноеИмяФайла, АдресаДоставки );
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает адреса доставки файлов из данных запроса согласно пользовательским настройкам маршрутизации
// или настройкам маршрутизации из файла настроек (См. ServicesSettings.RoutingFileName).
// Для пользовательских настроек приоритет выше, чем у настроек из файла. 
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// 	
// Возвращаемое значение:
// 	Соответствие - описание:
// 	*Ключ - Строка - идентификатор commit;
// 	*Значение - Соответствие - описание;
// 	** Ключ - Строка - полное имя файла;
// 	** Значение - Массив из Строка - адреса к сервисам получения файла;
//
Функция МаршрутыОтправкиФайловПоДаннымЗапроса( ДанныеЗапроса )
	
	Var Commits;
	Var НастройкиМаршрутизации;
	Var Результат;
	
	Результат = Новый Соответствие();
	
	Commits = ДанныеЗапроса.Получить( "commits" );
	
	Для каждого Commit Из Commits Цикл
		
		НастройкиМаршрутизации = Commit.Получить( "user_settings" );
		
		Если ( НастройкиМаршрутизации = Неопределено ) Тогда
			
			НастройкиМаршрутизации = Commit.Получить( "settings" );
			
		КонецЕсли;
		
		Если ( НастройкиМаршрутизации = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Результат.Вставить( Commit.Получить( "id" ), АдресаДоставкиФайлов( НастройкиМаршрутизации ) );

	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции 

#EndRegion