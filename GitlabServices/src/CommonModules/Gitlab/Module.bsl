#Region Public

// Возвращает параметры соединения к серверу GitLab по адресу и пользовательским настройкам подключения.
// 
// Параметры:
// 	Адрес - Строка - адрес к серверу GitLab, например, "http://www.example.org";
//
// Возвращаемое значение:
// 	Структура - Описание:
// * Адрес - Строка - адрес к серверу GitLab;
// * Token - Строка - token доступа к серверу GitLab из текущих настроек сервисов;
// * Таймаут - Число - таймаут подключения к GitLab из текущих настроек сервисов;
//
Функция ПараметрыСоединения( Знач Адрес ) Экспорт
	
	Var ТекущиеНастройки;
	Var Результат;
	
	ТекущиеНастройки = ServicesSettings.CurrentSettings();
	
	Результат = Новый Структура();
	Результат.Вставить( "Адрес", Адрес );
	Результат.Вставить( "Token", ТекущиеНастройки.TokenGitLab );
	Результат.Вставить( "Таймаут", ТекущиеНастройки.TimeoutGitLab );
	
	Возврат Результат;
	
КонецФункции

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
	
	Результат = GitLabПовтИсп.ОписаниеФайлов();
	
	// В кеше хранится ссылка, поэтому исключаем возможность возврата заполненного значения.
	Результат.Очистить();

	Возврат GitLabПовтИсп.ОписаниеФайлов();
	
КонецФункции

// Получает с сервера GitLab файл и формирует его описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. GitLab.ПараметрыСоединения)
// 	ПутьКФайлуRAW - Строка - закодированный в URL кодировке относительный путь к получаемому файлу, например,
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Возвращаемое значение:
// 	Структура - описание:
// * ПутьКФайлуRAW - Строка - относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла в кодировке UTF-8;
// * ДвоичныеДанные - ДвоичныеДанные - данные файла;
// * ОписаниеОшибки - Строка - текст с описанием ошибки получения файла с сервера;
//
Функция GetRemoteFile( Знач ПараметрыСоединения, Знач ПутьКФайлуRAW ) Экспорт

	Var Адрес;
	Var Заголовки;
	Var ДополнительныеПараметры;
	Var ИмяФайла;
	Var Ответ;
	Var ИнформацияОбОшибке;
	Var ТекстСообщения;
	Var Результат;
	
	Адрес = ПараметрыСоединения.Адрес + ПутьКФайлуRAW;
	
	Результат = ОписаниеПолучаемогоФайла();
	Результат.ПутьКФайлуRAW = ПутьКФайлуRAW;

	Попытка

		Заголовки = Новый Соответствие();
		Заголовки.Вставить( "PRIVATE-TOKEN", ПараметрыСоединения.Token );
		
		ДополнительныеПараметры = Новый Структура();
		ДополнительныеПараметры.Вставить( "Заголовки", Заголовки );
		ДополнительныеПараметры.Вставить( "Таймаут", ПараметрыСоединения.Таймаут );
		
		Ответ = HTTPConnector.Get( Адрес, Неопределено, ДополнительныеПараметры );

		Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
			
			ВызватьИсключение HTTPStatusCodesClientServerCached.FindIdByCode( Ответ.КодСостояния );
		
		КонецЕсли;
		
		ИмяФайла = Ответ.Заголовки.Получить( "X-Gitlab-File-Name" );
		
		Если ( ИмяФайла = Неопределено ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Файл не найден.';en = 'File not found.'");
			
		КонецЕсли;

		Если ( НЕ ЗначениеЗаполнено(Ответ.Тело) ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Пустой файл.';en = 'File is empty.'");
			
		КонецЕсли;

		Результат.ИмяФайла = ИмяФайла;
		Результат.ДвоичныеДанные = Ответ.Тело;
		
	Исключение
	
		ТекстСообщения = НСтр( "ru = 'Ошибка получения файла: %1';en = 'Error getting file: %1'" );
		ИнформацияОбОшибке = Адрес + Символы.ПС + ОбработкаОшибок.ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		Результат.ОписаниеОшибки = СтрШаблон( ТекстСообщения, ИнформацияОбОшибке );
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файлы и формирует их описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. GitLab.ПараметрыСоединения)
// 	ПутиКФайлам - Массив из Строка - массив закодированных в URL кодировке относительных путей к получаемым файлам,
//					например, "/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Возвращаемое значение:
// 	Массив из Структура:
// * ПутьКФайлуRAW - Строка - относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла в кодировке UTF-8;
// * ДвоичныеДанные - ДвоичныеДанные - данные файла;
// * ОписаниеОшибки - Строка - текст с описанием ошибки получения файла с сервера;
// 
Функция GetRemoteFiles( Знач ПараметрыСоединения, Знач ПутиКФайлам ) Экспорт
	
	Var Результат;

	Результат = Новый Массив;
	
	Для Каждого ПутьКФайлуRAW Из ПутиКФайлам Цикл
		
		Результат.Добавить( GetRemoteFile(ПараметрыСоединения, ПутьКФайлуRAW) );
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

// Возвращает описание файлов и сами файлы, которые необходимо распределить по информационным базам получателям.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
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
Функция ПолучитьФайлыКОтправкеПоДаннымЗапроса( Знач ОбработчикСобытия, ДанныеЗапроса ) Экспорт
	
	Var ПараметрыЛогирования;
	Var ПараметрыПроекта;
	Var ПараметрыСоединения;
	Var Результат;
	
	EVENT_MESSAGE_BEGIN = НСтр( "ru = 'Core.ПолучениеФайловGitLab.Начало';en = 'Core.ReceivingFilesGitLab.Begin'" );
	EVENT_MESSAGE = НСтр( "ru = 'Core.ПолучениеФайловGitLab';en = 'Core.ReceivingFilesGitLab'" );
	EVENT_MESSAGE_END = НСтр( "ru = 'Core.ПолучениеФайловGitLab.Окончание';en = 'Core.ReceivingFilesGitLab.End'" );
	
	RECEIVING_MESSAGE = НСтр("ru = 'получение файлов с сервера...';en = 'receiving files from the server...'");
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия ); 
	Логирование.Информация( EVENT_MESSAGE_BEGIN, RECEIVING_MESSAGE, ПараметрыЛогирования );	

	ПараметрыПроекта = ОписаниеПроекта( ДанныеЗапроса );
	Результат = ДействияНадФайламиПоДаннымЗапроса( ДанныеЗапроса, ПараметрыПроекта );
	Результат = ОписаниеФайловСрезПоследних( Результат );
	Маршрутизация.СформироватьОписаниеФайловМаршрутизации( Результат, ДанныеЗапроса, ПараметрыПроекта );

	ПараметрыСоединения = ПараметрыСоединения( ПараметрыПроекта.АдресСервера );
	
	ЗаполнитьОтправляемыеДанныеФайлами( Результат, ПараметрыСоединения );	

	Для Каждого ОписаниеФайла Из Результат Цикл
		
		Если ( НЕ ПустаяСтрока(ОписаниеФайла.ОписаниеОшибки) ) Тогда
			
			Логирование.Ошибка( EVENT_MESSAGE, ОписаниеФайла.ОписаниеОшибки, ПараметрыЛогирования );
			
		КонецЕсли;
			
	КонецЦикла;
	
	Логирование.Информация( EVENT_MESSAGE_END, RECEIVING_MESSAGE, ПараметрыЛогирования );	

	Возврат Результат;	
	
КонецФункции

// Возвращает десериализованный из JSON ответ сервера GitLab с описанием всех Merge Request проекта.
// Информация о проекте и адресе сервера GitLab определяется из данных запроса.
// 
// Параметры:
// 	QueryData - Соответствие - десериализованное из JSON тело запроса;
// Возвращаемое значение:
//   Массив, Соответствие, Структура - ответ, десериализованный из JSON. 
//
Function GetMergeRequestsByQueryData( Val QueryData ) Export
	
	Var ProjectParams;
	Var ConnectionParams;
	Var Headers;
	Var URL;
	Var AdditionalParams;
	
	ProjectParams = ОписаниеПроекта( QueryData );
	ConnectionParams = ПараметрыСоединения( ProjectParams.АдресСервера );
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Заголовки", Headers );
	AdditionalParams.Insert( "Таймаут", ConnectionParams.Таймаут );
	
	URL = ConnectionParams.Адрес + MergeRequestsPath( ProjectParams.Идентификатор );

	Return HTTPConnector.GetJson( URL, Undefined, AdditionalParams );
	
EndFunction

#EndRegion

#Region Internal

// Возвращает перекодированный в URL относительный путь к RAW файлу. 
// 
// Параметры:
// 	ProjectId - Строка - id проекта;
// 	ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// 	Commit - Строка - сommit SHA;
// 
// Возвращаемое значение:
// 	Строка - перекодированный в URL относительный путь к файлу.
//
Функция ПутьКФайлуRAW( Знач ProjectId, Знач ПолноеИмяФайла, Знач Commit ) Экспорт
	
	Var Шаблон;
	
	Шаблон = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	ПолноеИмяФайла = КодироватьСтроку( ПолноеИмяФайла, СпособКодированияСтроки.КодировкаURL );
	
	Возврат СтрШаблон( Шаблон, ProjectId, ПолноеИмяФайла, Commit );
	
КонецФункции

#EndRegion

#Region Private

// Возвращает описание проекта GitLab по данным запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
//
// Возвращаемое значение:
// 	Структура - Описание:
// * Идентификатор - Строка - числовой идентификатор проекта (репозитория);
// * АдресСервера - Строка - адрес сервера вместе со схемой обращения к серверу;
// 
Функция ОписаниеПроекта( Знач ДанныеЗапроса )
	
	Var ОписаниеПроекта;
	Var URL;
	Var НачалоОтносительногоПути;
	Var АдресСервера;
	Var Результат;
	
	ОписаниеПроекта = ДанныеЗапроса.Получить( "project" );

	URL = ОписаниеПроекта.Получить( "http_url" );
	НачалоОтносительногоПути = СтрНайти( URL, "/", , , 3 ) - 1;
	
	АдресСервера = "";
	
	Если ( НачалоОтносительногоПути > 0 ) Тогда
		
		АдресСервера = Лев( URL, НачалоОтносительногоПути );
		
	КонецЕсли;	
			
	Результат = Новый Структура();
	Результат.Вставить( "Идентификатор", Строка(ОписаниеПроекта.Получить("id")) );
	Результат.Вставить( "АдресСервера", АдресСервера );	

	Возврат Результат;
	
КонецФункции

Function MergeRequestsPath( Val ProjectId )
	
	Return StrTemplate( "/api/v4/projects/%1/merge_requests", ProjectId );
	
EndFunction

// Возвращает перечень возможных действий над файлами в соответствии с REST API GitLab.
// 
// Возвращаемое значение:
// 	Массив - "added", "modified", "removed";
//
Функция ПереченьОперацийНадФайлами()
		
	Возврат GitLabПовтИсп.ПереченьОперацийНадФайлами();
	
КонецФункции

// Возвращает результат проверки, что файл является скомпилированным файлом внешнего отчета или обработки.
// 
// Параметры:
// 	ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
//
// Возвращаемое значение:
// 	Булево - Истина - это скомпилированный файл, иначе - Ложь;
//
Функция ЭтоСкомпилированныйФайл( Знач ПолноеИмяФайла )
	
	Возврат ( СтрЗаканчиваетсяНа(ПолноеИмяФайла, ".epf") ИЛИ СтрЗаканчиваетсяНа(ПолноеИмяФайла, ".erf") );
	
КонецФункции

Функция ОписаниеФайловСрезПоследних( Знач ОписаниеФайлов, Знач Операция = "modified" )
	
	Var Результат;
	Var ПараметрыОтбора;
	Var НайденныеСтроки;
	
	Результат = ОписаниеФайлов.СкопироватьКолонки();
	ПолныеИменаФайлов = ОбщегоНазначенияКлиентСервер.СвернутьМассив( ОписаниеФайлов.ВыгрузитьКолонку("ПолноеИмяФайла") );
	
	Если ( НЕ ЗначениеЗаполнено(ПолныеИменаФайлов) ) Тогда
		
		Возврат Результат;
	
	КонецЕсли;
	
	ОписаниеФайлов.Сортировать( "Дата Убыв" );
	
	ПараметрыОтбора = Новый Структура( "ПолноеИмяФайла, Операция" );
	ПараметрыОтбора.Операция = Операция;
			
	Для каждого ПолноеИмяФайла Из ПолныеИменаФайлов Цикл

		ПараметрыОтбора.ПолноеИмяФайла = ПолноеИмяФайла;
		НайденныеСтроки = ОписаниеФайлов.НайтиСтроки( ПараметрыОтбора );

		Если ( НЕ ЗначениеЗаполнено(НайденныеСтроки) ) Тогда

			Продолжить;
								
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств( Результат.Добавить(), НайденныеСтроки[0] );
		
	КонецЦикла;

	Возврат Результат;
	
КонецФункции

Функция ДействияНадФайламиПоДаннымЗапроса( Знач ДанныеЗапроса, Знач ПараметрыПроекта )
	
	Var Commits;
	Var CommitSHA;
	Var Дата;
	Var ПолныеИменаФайлов;
	Var ПутьКФайлуRAW;
	Var НоваяСтрока;
	Var Результат;
	
	Commits = ДанныеЗапроса.Получить( "commits" );
	Результат = ОписаниеФайлов();
	
	Для каждого Commit Из Commits Цикл

		CommitSHA = Commit.Получить( "id" );
		Дата = Commit.Получить( "timestamp" );
		
		Для каждого Действие Из ПереченьОперацийНадФайлами() Цикл

			ПолныеИменаФайлов = Commit.Получить( Действие );

			Для каждого ПолноеИмяФайла Из ПолныеИменаФайлов Цикл
				
				Если ( НЕ ЭтоСкомпилированныйФайл(ПолноеИмяФайла) ) Тогда
					
					Продолжить;

				КонецЕсли;

				НоваяСтрока = Результат.Добавить();
				ПутьКФайлуRAW = ПутьКФайлуRAW( ПараметрыПроекта.Идентификатор, ПолноеИмяФайла, CommitSHA );
				НоваяСтрока.ПутьКФайлуRAW = ПутьКФайлуRAW;
				НоваяСтрока.ПолноеИмяФайла = ПолноеИмяФайла;
				НоваяСтрока.Операция = Действие;
				НоваяСтрока.Дата = Дата;
				НоваяСтрока.CommitSHA = CommitSHA;

			КонецЦикла;

		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаполнитьОтправляемыеДанныеФайлами( ОтправляемыеДанные, Знач ПараметрыСоединения )

	Var ПутиКФайлам;
	Var Файл;
	Var Файлы;

	ПутиКФайлам = ОтправляемыеДанные.ВыгрузитьКолонку( "ПутьКФайлуRAW" );
	Файлы = GetRemoteFiles( ПараметрыСоединения, ПутиКФайлам );
	
	Для каждого ОписаниеФайла Из Файлы Цикл
			
		Файл = ОтправляемыеДанные.Найти( ОписаниеФайла.ПутьКФайлуRAW, "ПутьКФайлуRAW" );
		ЗаполнитьЗначенияСвойств( Файл, ОписаниеФайла );

	КонецЦикла;

КонецПроцедуры

Функция ОписаниеПолучаемогоФайла()

	Var Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "ПутьКФайлуRAW", "" );
	Результат.Вставить( "ИмяФайла", "" );
	Результат.Вставить( "ДвоичныеДанные", Неопределено );
	Результат.Вставить( "ОписаниеОшибки", "" );
	
	Возврат Результат;

КонецФункции

#EndRegion