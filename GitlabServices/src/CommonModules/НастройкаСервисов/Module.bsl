#Область ПрограммныйИнтерфейс

// Возвращает фиксированную структуру со всеми текущими настройками механизмов управления сервисами GitLab.
// 
// Параметры:
// Возвращаемое значение:
// ФиксированнаяСтруктура - описание:
// * ЗагружатьФайлыИзВнешнегоХранилища - Булево - (См. Константа.ЗагружатьФайлыИзВнешнегоХранилища);
// * ИмяФайлаНастроекМаршрутизации - Строка - (См. Константа.ИмяФайлаНастроекМаршрутизации);
// * GitLabUserPrivateToken - Строка - (См. Константа.GitLabUserPrivateToken);
// * ТаймаутGitLab - Число - (См. Константа.ТаймаутGitLab);
// * AccessTokenReceiver - Строка - (См. Константа.AccessTokenReceiver);
// * ТаймаутДоставкиПолучатель - Число - (См. Константа.ТаймаутДоставкиПолучатель);
//
Функция НастройкиСервисовGitLab() Экспорт
	
	Перем Результат;
	Перем ТекстСообщения;

	Попытка
		
		Результат = Новый Структура();
		Результат.Вставить( "ЗагружатьФайлыИзВнешнегоХранилища", ЗагружатьФайлыИзВнешнегоХранилища() );
		Результат.Вставить( "ИмяФайлаНастроекМаршрутизации", ИмяФайлаНастроекМаршрутизации() );
		Результат.Вставить( "GitLabUserPrivateToken", GitLabUserPrivateToken() );
		Результат.Вставить( "ТаймаутGitLab", ТаймаутGitLab() );
		Результат.Вставить( "AccessTokenReceiver", AccessTokenReceiver() );
		Результат.Вставить( "ТаймаутДоставкиПолучатель", ТаймаутДоставкиПолучатель() );
		
		Результат = Новый ФиксированнаяСтруктура( Результат );
		
	Исключение
		
		ТекстСообщения = СтрШаблон( НСтр("ru = '%1'"), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()) );
		Логирование.Ошибка( "Core.Настройки", ТекстСообщения );
		ВызватьИсключение;
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Параметры доставки данных до веб-сервиса обслуживания внешних отчетов и обработок в информационной базе получателе.
// 
// Параметры:
// Возвращаемое значение:
// 	Структура - Описание:
// * Адрес - Строка - адрес веб-сервиса для работы с внешними отчетами и обработками в информационной базе получателе;
// * Token - Строка - token доступа к сервису получателя;
// * Таймаут - Число - таймаут соединения с сервисом, секунд (если 0 - таймаут не установлен);
//
Функция ПараметрыСервисаПолучателя() Экспорт
	
	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "Адрес", "localhost/receiver/hs/gitlab" );
	Результат.Вставить( "Token", AccessTokenReceiver() );
	Результат.Вставить( "Таймаут", ТаймаутДоставкиПолучатель() );
	
	Возврат Результат;
	
КонецФункции

// Получает значение константы с именем файла настроек маршрутизации, расположенном в корне репозитория GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Строка - имя файла (макс. 50);
//
Функция ИмяФайлаНастроекМаршрутизации() Экспорт
	
	Возврат Константы.ИмяФайлаНастроекМаршрутизации.Получить();
	
КонецФункции

// Получает значение константы с private token пользователя GitLab с правами доступа к API GitLab.
// 
// Параметры:
// Возвращаемое значение:
// 	Строка - значение PRIVATE-TOKEN (макс. 50);
// 
Функция GitLabUserPrivateToken() Экспорт
	
	Возврат Константы.GitLabUserPrivateToken.Получить();
	
КонецФункции

// Получает значение константы с таймаутом соединения к серверу GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Число - таймаут соединения, секунд (0 - таймаут не установлен);
//
Функция ТаймаутGitLab() Экспорт
	
	Возврат Константы.ТаймаутGitLab.Получить();

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Получает значение настройки разрешения включения/отключения функционала загрузки файлов из внешнего хранилища GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Булево - Истина - загружать, Ложь - загрузка запрещена;
//
Функция ЗагружатьФайлыИзВнешнегоХранилища()
	
	Возврат Константы.ЗагружатьФайлыИзВнешнегоХранилища.Получить();

КонецФункции

// Получает значение константы AccessTokenReceiver, используемое для подключения к сервисам
// конечных точек доставки файлов.
// 
// Параметры:
// Возвращаемое значение:
// 	Строка - token подключения к базе получателю (макс. 20);
// 
Функция AccessTokenReceiver()
	
	Возврат Константы.AccessTokenReceiver.Получить();
	
КонецФункции

// Получает значение константы с таймаутом соединения к веб-сервису информационной базы получателя.
//
// Параметры:
// Возвращаемое значение:
// 	Число - таймаут соединения, секунд (0 - таймаут не установлен);
//
Функция ТаймаутДоставкиПолучатель()
	
	Возврат Константы.ТаймаутДоставкиПолучатель.Получить();
	
КонецФункции

#КонецОбласти