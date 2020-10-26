#Region Private

#Область HTTPМетоды

Функция ServicesGET( Запрос )
	
	Var ОписаниеСервиса;
	Var Ответ;
	
	Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	ОписаниеСервиса = HTTPСервисы.ОписаниеСервиса( "gitlab" );
	
	ТелоОтвета = Новый Структура();
	ТелоОтвета.Вставить( "version", Метаданные.Версия );
	ТелоОтвета.Вставить( "services", ОписаниеСервиса );
	
	Ответ.Заголовки.Вставить( "Content-Type", "application/json" );
	Ответ.УстановитьТелоИзСтроки( HTTPConnector.ОбъектВJson(ТелоОтвета) );
	
	Возврат Ответ;
	
КонецФункции

Функция WebhooksPOST( Запрос )
	
	Var ОбработчикСобытия;
	Var ДанныеЗапроса;
	Var Ответ;
	Var ПараметрыЛогирования;
	
	Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	ТекстСообщения = НСтр( "ru = 'Получен запрос с сервера GitLab.'" );
	Логирование.Информация( "GitLab.ОбработкаЗапроса.Начало", ТекстСообщения );
	
	ОбработчикСобытия = Неопределено;
	ПроверитьСекретныйКлюч( Запрос, Ответ, ОбработчикСобытия );
	ОпределитьДоступностьФункциональностиЗагрузкиИзВнешнегоРепозитория( Ответ );
	ПроверитьЗаголовкиЗапросаWebhooksPOST( ОбработчикСобытия, Запрос, Ответ );

	ДанныеЗапроса = Неопределено;
	ДесериализоватьТелоЗапроса( ОбработчикСобытия, Запрос, Ответ, ДанныеЗапроса );
	ПроверитьНаличиеОбязательныхДанныхВТелеЗапроса( ОбработчикСобытия, ДанныеЗапроса, Ответ );
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( , Ответ );
	
	Если ( HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда

		ТекстСообщения = НСтр( "ru = 'Запрос с сервера GitLab обработан.'" );
		Логирование.Информация( "GitLab.ОбработкаЗапроса.Окончание", ТекстСообщения, ПараметрыЛогирования );
		
		ОбработкаДанных.НачатьЗапускОбработкиДанных( ОбработчикСобытия, ДанныеЗапроса );
		
	КонецЕсли;

	Возврат Ответ;
	
КонецФункции

#EndRegion

Процедура ПроверитьСекретныйКлюч( Знач Запрос, Ответ, ОбработчикСобытия )

	Var Token;
	Var ТекстСообщения;	
	Var ПараметрыЛогирования;
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Token = Запрос.Заголовки.Получить( "X-Gitlab-Token" );
	ОбработчикСобытия = ОбработчикиСобытий.НайтиПоСекретномуКлючу( Token );

	Если ( НЕ ЗначениеЗаполнено(ОбработчикСобытия) ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("FORBIDDEN") );
		
		ПараметрыЛогирования = Логирование.ДополнительныеПараметры( , Ответ );
		ТекстСообщения = НСтр( "ru = 'Секретный ключ не найден.'" );
		Логирование.Предупреждение( "GitLab.ОбработкаЗапроса", ТекстСообщения, ПараметрыЛогирования );
										 
	КонецЕсли;

КонецПроцедуры

Процедура ОпределитьДоступностьФункциональностиЗагрузкиИзВнешнегоРепозитория( Ответ )
	
	Var ТекстСообщения;
	Var ПараметрыЛогирования;
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если ( НЕ ПолучитьФункциональнуюОпцию("ОбрабатыватьЗапросыВнешнегоХранилища") ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("LOCKED") );
		Ответ.Причина = "Loading of the files is disabled";
		
		ПараметрыЛогирования = Логирование.ДополнительныеПараметры( , Ответ );
		ТекстСообщения = НСтр( "ru = 'Отключен функционал загрузки из внешнего хранилища.'" );
		Логирование.Предупреждение( "GitLab.ОбработкаЗапроса", ТекстСообщения, ПараметрыЛогирования );

	КонецЕсли;

КонецПроцедуры

// Проверяет что запрос пришел от репозитория для хранения внешних отчетов и обработок.
// 
// Параметры:
// 	Запрос - Запрос - HTTP-запрос;
//
// Возвращаемое значение:
// 	Булево - Истина, если это репозиторий для внешних отчетов и обработок, иначе - Ложь.
//
Функция ЭтоРепозиторийВнешнихОтчетовИОбработок( Знач Запрос )
	
	Var ТипВнешнегоХранилища;
	
	ТипВнешнегоХранилища = Запрос.ПараметрыURL.Получить( "ТипВнешнегоХранилища" );
	Возврат ( ТипВнешнегоХранилища <> Неопределено И ТипВнешнегоХранилища = "epf" );
	
КонецФункции

// Проверяет является ли запрос событием "Push Hook" и end-point выбран push.
// 
// Параметры:
// 	Запрос - HTTPСервисЗапрос - HTTP-запрос;
//
// Возвращаемое значение:
// 	Булево - Истина - запрос является Push Hook, иначе - Ложь.
//
Функция ЭтоСобытиеPush( Знач Запрос )
	
	Var Событие;
	Var ИмяМетода;
	
	Событие = Запрос.Заголовки.Получить( "X-Gitlab-Event" );
	ИмяМетода = Запрос.ПараметрыURL.Получить( "ИмяМетода" );
	
	Возврат ( ЗначениеЗаполнено(Событие) И (Событие = "Push Hook") И (ИмяМетода = "push") );
	
КонецФункции

Процедура ПроверитьЗаголовкиЗапросаWebhooksPOST( Знач ОбработчикСобытия, Знач Запрос, Ответ )
	
	Var ТекстСообщения;
	Var ПараметрыЛогирования;
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;

	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );

	Если ( НЕ ЭтоРепозиторийВнешнихОтчетовИОбработок(Запрос) ) Тогда

		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		ТекстСообщения = НСтр( "ru = 'Сервис доступен только для внешних отчетов и обработок.'" );
		Логирование.Предупреждение( "GitLab.ОбработкаЗапроса", ТекстСообщения, ПараметрыЛогирования );
												 
		Возврат;
	
	КонецЕсли;
	
	Если ( НЕ ЭтоСобытиеPush(Запрос) ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		ТекстСообщения = НСтр( "ru = 'Сервис обрабатывает только события ""Push Hook"".'" );
		Логирование.Предупреждение( "GitLab.ОбработкаЗапроса", ТекстСообщения, ПараметрыЛогирования );
												 
		Возврат;
	
	КонецЕсли;
	
КонецПроцедуры

// Десериализует тело HTTP запроса из формата JSON.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	Запрос - HTTPСервисЗапрос - HTTP-запрос;
// 	Ответ - HTTPСервисОтвет - HTTP-ответ;
// 	ДанныеЗапроса - Соответствие - (исходящий параметр) десериализованное из JSON тело запроса; исходный текст тела запроса
//		добавляется в структуру с ключом "json".
//
Процедура ДесериализоватьТелоЗапроса( Знач ОбработчикСобытия, Знач Запрос, Знач Ответ, ДанныеЗапроса = Неопределено )
	
	Var Поток;
	Var ПараметрыПреобразования;
	Var ПараметрыЛогирования;
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	ТекстСообщения = НСтр( "ru = 'Начало получения тела запроса...'" );
	Логирование.Информация( "GitLab.ОбработкаЗапроса.Начало", ТекстСообщения, ПараметрыЛогирования );
	
	Попытка
		
		Поток = Запрос.ПолучитьТелоКакПоток();
		
		ПараметрыПреобразования = Новый Структура();
		ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
		ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
		
		ДанныеЗапроса = HTTPConnector.JsonВОбъект( Поток, , ПараметрыПреобразования );
		ОбщегоНазначения.ДополнитьКоллекциюТекстомИзПотока( Поток, "json", ДанныеЗапроса );
		
		Поток.Закрыть();
		
		ТекстСообщения = НСтр( "ru = 'Окончание получения тела запроса...'" );
		Логирование.Информация( "GitLab.ОбработкаЗапроса.Окончание", ТекстСообщения, ПараметрыЛогирования );

	Исключение
		
		Поток.Закрыть();
		ТекстСообщения = НСтр( "ru = '" + ИнформацияОбОшибке().Описание + "'" );
		Логирование.Ошибка( "GitLab.ОбработкаЗапроса", ТекстСообщения, ПараметрыЛогирования );
		
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

Функция ПроверяемыеЭлементы( Знач ДанныеЗапроса )
	
	Var Проект;
	Var Коммиты;
	Var Результат;
	
	Результат = Новый Соответствие();
	Результат.Вставить( "тело запроса" , ДанныеЗапроса ); //TODO что за шляпа "тело запроса", непонятно, может root?		
	Результат.Вставить( "checkout_sha" , ДанныеЗапроса.Получить("checkout_sha") );
	
	Проект = ДанныеЗапроса.Получить("project");
	Результат.Вставить( "project" , Проект );
	
	Если ( Проект <> Неопределено ) Тогда
		
		Результат.Вставить( "project/web_url" , Проект.Получить("web_url") );
		Результат.Вставить( "project/id" , Проект.Получить("id") );
		
	КонецЕсли;
	
	Коммиты = ДанныеЗапроса.Получить("commits");
	Результат.Вставить( "commits" , Коммиты );
	
	Если ( Коммиты <> Неопределено ) Тогда
		
		Для Индекс = 0 По Коммиты.ВГраница() Цикл
			
			Результат.Вставить( "commits[" + Строка(Индекс) + "]/id", Коммиты[Индекс].Получить("id") );
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Проверяет сериализованные данные тела запроса на наличие обязательных данных.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	ДанныеЗапроса - Соответствие - сериализованные данные HTTP-запроса;
// 	Ответ - HTTPСервисОтвет - HTTP-ответ;
//
Процедура ПроверитьНаличиеОбязательныхДанныхВТелеЗапроса( Знач ОбработчикСобытия, Знач ДанныеЗапроса, Ответ )
	
	Var ТекстСообщения;
	Var ПараметрыЛогирования;
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	ТекстСообщения = НСтр("ru = 'Начало проверки тела запроса...'");
	Логирование.Информация( "GitLab.ПроверкаЗапроса.Начало", ТекстСообщения, ПараметрыЛогирования );
	
	Коллекция = ПроверяемыеЭлементы( ДанныеЗапроса );
	
	Для Каждого Элемент Из Коллекция Цикл
		
		Если ( Элемент.Значение = Неопределено ) Тогда
			
			Ответ = Новый HTTPСервисОтвет(HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST"));
			ТекстСообщения = НСтр( "ru = 'В данных запроса отсутствует %1.'" );
			ТекстСообщения = СтрШаблон( ТекстСообщения, Элемент.Ключ );
			Логирование.Ошибка( "GitLab.ПроверкаЗапроса", ТекстСообщения, ПараметрыЛогирования );
			
			Возврат;		
			
		КонецЕсли;		
		
	КонецЦикла;
	
	ТекстСообщения = НСтр( "ru = 'Окончание проверки тела запроса...'" );
	Логирование.Информация( "GitLab.ПроверкаЗапроса.Окончание", ТекстСообщения, ПараметрыЛогирования );
	
КонецПроцедуры

#EndRegion