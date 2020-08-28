#Область ПрограммныйИнтерфейс

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
	
	Перем ТекущиеНастройки;
	Перем Результат;
	
	ТекущиеНастройки = НастройкаСервисов.ТекущиеНастройки();
	
	Результат = Новый Структура();
	Результат.Вставить( "Адрес", Адрес );
	Результат.Вставить( "Token", ТекущиеНастройки.GitLabUserPrivateToken );
	Результат.Вставить( "Таймаут", ТекущиеНастройки.ТаймаутGitLab );
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файл и формирует его описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. Gitlab.ПараметрыСоединения)
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
Функция ПолучитьФайл( Знач ПараметрыСоединения, Знач ПутьКФайлуRAW ) Экспорт

	Перем Адрес;
	Перем Заголовки;
	Перем ДополнительныеПараметры;
	Перем ИмяФайла;
	Перем Ответ;
	Перем ИнформацияОбОшибке;
	Перем ТекстСообщения;
	Перем Результат;
	
	Адрес = ПараметрыСоединения.Адрес + ПутьКФайлуRAW;
	
	Результат = ОписаниеПолучаемогоФайла();
	Результат.ПутьКФайлуRAW = ПутьКФайлуRAW;

	Попытка

		Заголовки = Новый Соответствие();
		Заголовки.Вставить( "PRIVATE-TOKEN", ПараметрыСоединения.Token );
		
		ДополнительныеПараметры = Новый Структура();
		ДополнительныеПараметры.Вставить( "Заголовки", Заголовки );
		ДополнительныеПараметры.Вставить( "Таймаут", ПараметрыСоединения.Таймаут );
		
		Ответ = КоннекторHTTP.Get( Адрес, Неопределено, ДополнительныеПараметры );

		Если ( НЕ КодыСостоянияHTTPКлиентСерверПовтИсп.isOk(Ответ.КодСостояния) ) Тогда
			
			ВызватьИсключение КодыСостоянияHTTPКлиентСерверПовтИсп.НайтиИдентификаторПоКоду( Ответ.КодСостояния );
		
		КонецЕсли;
		
		ИмяФайла = Ответ.Заголовки.Получить( "X-Gitlab-File-Name" );
		
		Если ( ИмяФайла = Неопределено ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Файл не найден.'");
			
		КонецЕсли;

		Если ( НЕ ЗначениеЗаполнено(Ответ.Тело) ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Пустой файл.'");
			
		КонецЕсли;

		Результат.ИмяФайла = ИмяФайла;
		Результат.ДвоичныеДанные = Ответ.Тело;
		
	Исключение
	
		ТекстСообщения = НСтр( "ru = 'Ошибка получения файла: %1'" );
		ИнформацияОбОшибке = Адрес + Символы.ПС + ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		Результат.ОписаниеОшибки = СтрШаблон( ТекстСообщения, ИнформацияОбОшибке );
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файлы и формирует их описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. Gitlab.ПараметрыСоединения)
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
Функция ПолучитьФайлы( Знач ПараметрыСоединения, Знач ПутиКФайлам ) Экспорт
	
	Перем Результат;

	Результат = Новый Массив;
	
	Для Каждого ПутьКФайлуRAW Из ПутиКФайлам Цикл
		
		Результат.Добавить( ПолучитьФайл(ПараметрыСоединения, ПутьКФайлуRAW) );
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

// Возвращает описание файлов и сами файлы, которые необходимо распределить по информационным базам получателям.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	ДанныеЗапроса - Соответствие - преобразованное в коллекцию тело запроса;
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
//
Функция ПолучитьФайлыКОтправкеПоДаннымЗапроса( Знач ОбработчикСобытия, ДанныеЗапроса ) Экспорт
	
	Перем ДополнительныеПараметры;
	Перем ПараметрыПроекта;
	Перем ПараметрыСоединения;
	Перем Результат;
	
	ДополнительныеПараметры = Логирование.ДополнительныеДанные();
	ДополнительныеПараметры.Объект = ОбработчикСобытия;
	Логирование.Информация("Core.ПолучениеФайловСGitLab.Начало", "Начало", ДополнительныеПараметры);	

	ПараметрыПроекта = ОписаниеПроекта( ДанныеЗапроса );
	Результат = ДействияНадФайламиПоДаннымЗапроса( ДанныеЗапроса, ПараметрыПроекта );
	Результат = ОписаниеФайловСрезПоследних( Результат );
	ПараметрыСоединения = ПараметрыСоединения( ПараметрыПроекта.АдресСервера);
	ЗаполнитьОтправляемыеДанныеФайлами( Результат, ПараметрыСоединения );	

	Для Каждого ОписаниеФайла Из Результат Цикл
		
		Если ( НЕ ПустаяСтрока(ОписаниеФайла.ОписаниеОшибки) ) Тогда
			
			Логирование.Ошибка( "Core.ПолучениеФайловСGitLab", ОписаниеФайла.ОписаниеОшибки, ДополнительныеПараметры );
			
		КонецЕсли;
			
	КонецЦикла;
	
	Логирование.Информация("Core.ПолучениеФайловСGitLab.Начало", "Окончание", ДополнительныеПараметры);	

	Возврат Результат;	
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

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
	
	Перем Шаблон;
	
	Шаблон = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	ПолноеИмяФайла = КодироватьСтроку( ПолноеИмяФайла, СпособКодированияСтроки.КодировкаURL );
	
	Возврат СтрШаблон(Шаблон, ProjectId, ПолноеИмяФайла, Commit);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает описание проекта GitLab по данным запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - преобразованное в коллекцию тело запроса;
//
// Возвращаемое значение:
// 	Структура - Описание:
// * Идентификатор - Строка - числовой идентификатор проекта (репозитория);
// * АдресСервера - Строка - адрес сервера вместе со схемой обращения к серверу;
// 
Функция ОписаниеПроекта( Знач ДанныеЗапроса )
	
	Перем ОписаниеПроекта;
	Перем URL;
	Перем НачалоОтносительногоПути;
	Перем АдресСервера;
	Перем Результат;
	
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

// Возвращает перечень возможных действий над файлами в соответствии с REST API GitLab.
// 
// Возвращаемое значение:
// 	Массив - "added", "modified", "removed";
//
Функция ПереченьОперацийНадФайлами()
		
	Возврат GitlabПовтИсп.ПереченьОперацийНадФайлами();
	
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
//
Функция ОписаниеФайлов()

	Перем Результат;
	
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить( "ПутьКФайлуRAW", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	Результат.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "Дата", Новый ОписаниеТипов("Дата") );
	Результат.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	Результат.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));

	Возврат Результат;
	
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
	
	Перем Результат;
	Перем ПараметрыОтбора;
	Перем НайденныеСтроки;
	
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

		Если ( НайденныеСтроки = Неопределено ) Тогда

			Продолжить;
								
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств( Результат.Добавить(), НайденныеСтроки[0] );
		
	КонецЦикла;

	Возврат Результат;
	
КонецФункции

Функция ДействияНадФайламиПоДаннымЗапроса( Знач ДанныеЗапроса, Знач ПараметрыПроекта )
	
	Перем Commits;
	Перем CommitSHA;
	Перем Дата;
	Перем ПолныеИменаФайлов;
	Перем НоваяСтрока;
	Перем Результат;
	
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
				ПутьКФайлуRAW = Gitlab.ПутьКФайлуRAW( ПараметрыПроекта.Идентификатор, ПолноеИмяФайла, CommitSHA );
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

	Перем ПутиКФайлам;
	Перем Файл;
	Перем Файлы;

	ПутиКФайлам = ОтправляемыеДанные.ВыгрузитьКолонку( "ПутьКФайлуRAW" );
	Файлы = ПолучитьФайлы( ПараметрыСоединения, ПутиКФайлам );
	
	Для каждого ОписаниеФайла Из Файлы Цикл
			
		Файл = ОтправляемыеДанные.Найти( ОписаниеФайла.ПутьКФайлуRAW, "ПутьКФайлуRAW" );
		ЗаполнитьЗначенияСвойств( Файл, ОписаниеФайла );

	КонецЦикла;

КонецПроцедуры

Функция ОписаниеПолучаемогоФайла()

	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "ПутьКФайлуRAW", "" );
	Результат.Вставить( "ИмяФайла", "" );
	Результат.Вставить( "ДвоичныеДанные", Неопределено );
	Результат.Вставить( "ОписаниеОшибки", "" );
	
	Возврат Результат;

КонецФункции

#КонецОбласти