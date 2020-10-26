#Область СлужебныйПрограммныйИнтерфейс

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПараметрыСоединения(Фреймворк) Экспорт
	
	// given
	Константы.GitLabUserPrivateToken.Установить("-U2ssrBsM4rmx85HXzZ1");
	Константы.ТаймаутGitLab.Установить(5);
	// when
	Результат = Gitlab.ПараметрыСоединения("http://www.example.org");
	// then
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 3);
	Фреймворк.ПроверитьРавенство(Результат.Адрес, "http://www.example.org");
	Фреймворк.ПроверитьРавенство(Результат.Token, "-U2ssrBsM4rmx85HXzZ1");
	Фреймворк.ПроверитьРавенство(Результат.Таймаут, 5);

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайлФэйкURL(Фреймворк) Экспорт
	
	// given
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", "http://фэйк" );
	ПараметрыСоединения.Вставить( "Token", "-U2ssrBsM4rmx85HXzZ1" );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );

	ПутьКФайлуRAW = "/test";
	
	// when
	Результат = Gitlab.ПолучитьФайл(ПараметрыСоединения, ПутьКФайлуRAW);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ОписаниеОшибки, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ОписаниеОшибки, "Couldn't resolve host name");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайл404NotFound(Фреймворк) Экспорт

	// given
	URL = "http://mock-server:1080";

	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", URL );
	ПараметрыСоединения.Вставить( "Token", "-U2ssrBsM4rmx85HXzZ1" );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );
	
	ФэйкПутьКФайлуRAW = "/фэйк.epf";

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь("/%D1%84%D1%8D%D0%B9%D0%BA.epf")
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", "-U2ssrBsM4rmx85HXzZ1")
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(404)
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.ПолучитьФайл(ПараметрыСоединения, ФэйкПутьКФайлуRAW);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ОписаниеОшибки, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ОписаниеОшибки, HTTPStatusCodesClientServerCached.FindIdByCode(404));
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайл401Unauthorized(Фреймворк) Экспорт
	
	// given
	URL = "http://mock-server:1080";
	ФэйкGitLabUserPrivateToken = "1234567890";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", URL );
	ПараметрыСоединения.Вставить( "Token", ФэйкGitLabUserPrivateToken );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );
	
	ПутьКФайлуRAW = "/path/test.epf";

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW).Заголовок("PRIVATE-TOKEN", "!-U2ssrBsM4rmx85HXzZ1")
    	)
	    .Ответить(
	        Мок.Ответ().КодОтвета(401)
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.ПолучитьФайл(ПараметрыСоединения, ПутьКФайлуRAW);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ОписаниеОшибки, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ОписаниеОшибки, HTTPStatusCodesClientServerCached.FindIdByCode(401));
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайлПустой(Фреймворк) Экспорт
	
	// given	
	URL = "http://mock-server:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	Commit = "commit";
	ПутьКФайлуRAW = "/path/raw";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь(ПутьКФайлуRAW)
				.ПараметрСтрокиЗапроса("ref", Commit)
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200)
				.Заголовки()
					.Заголовок("X-Gitlab-File-Name", "test.epf")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.ПолучитьФайл(ПараметрыСоединения, ПутьКФайлуRAW + "?ref=" + Commit);

	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ОписаниеОшибки, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ОписаниеОшибки, НСтр("ru = 'Пустой файл.'"));
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайл200Ok(Фреймворк) Экспорт
	
	// given	
	URL = "http://mock-server:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );
	
	Commit = "ef3529e5486ff39c6439ab5d745eb56588202b86";
	ПутьКФайлуRAW = КодироватьСтроку(	"Каталог с отчетами и обработками/Внешняя Обработка 1.epf",
									СпособКодированияСтроки.КодировкаURL );
	ПутьКФайлуRAW = СтрШаблон("/api/v4/projects/1/repository/files/%1/raw?ref=%2", ПутьКФайлуRAW, Commit);
	
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь("/api/v4/projects/1/repository/files/%D0%9A%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%20%D1%81%20%D0%BE%D1%82%D1%87%D0%B5%D1%82%D0%B0%D0%BC%D0%B8%20%D0%B8%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%D0%BC%D0%B8%2F%D0%92%D0%BD%D0%B5%D1%88%D0%BD%D1%8F%D1%8F%20%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%201.epf/raw")
				.ПараметрСтрокиЗапроса("ref", "ef3529e5486ff39c6439ab5d745eb56588202b86")
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200)
				.Заголовки()
					.Заголовок("X-Gitlab-File-Name", "cyrillic not work 1.epf")
				.Тело("some_response_body")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.ПолучитьФайл(ПараметрыСоединения, ПутьКФайлуRAW);
	
	// then	
	Фреймворк.ПроверитьТип(Результат, "Структура");
	Фреймворк.ПроверитьРавенство(Результат.ПутьКФайлуRAW, ПутьКФайлуRAW);
	Фреймворк.ПроверитьРавенство(Результат.ИмяФайла, "cyrillic not work 1.epf");
	Фреймворк.ПроверитьТип(Результат.ДвоичныеДанные, "ДвоичныеДанные");
	Фреймворк.ПроверитьРавенство(Результат.ОписаниеОшибки, "");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайлы(Фреймворк) Экспорт
	
	// given	
	URL = "http://mock-server:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	
	CommitSHA = "commit";
	ПутьКФайлуRAW1 = "/path/test1.epf";
	ПутьКФайлуRAW2 = "/path/test2.epf";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "Адрес", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Таймаут", 5 );

	ПутиКФайлам = Новый Массив;
	ПутиКФайлам.Добавить(ПутьКФайлуRAW1 + "?ref=" + CommitSHA);
	ПутиКФайлам.Добавить(ПутьКФайлуRAW2 + "?ref=" + CommitSHA);
	ПутиКФайлам.Добавить("/фэйк");
	
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW1).ПараметрСтрокиЗапроса("ref", CommitSHA).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test1.epf").Тело("some_response_body")
	    );
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW2).ПараметрСтрокиЗапроса("ref", CommitSHA).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test2.epf").Тело("some_response_body")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.ПолучитьФайлы(ПараметрыСоединения, ПутиКФайлам);
	
	// then	
	Фреймворк.ПроверитьТип(Результат, "Массив");
	Фреймворк.ПроверитьРавенство(Результат[0].ПутьКФайлуRAW, ПутьКФайлуRAW1 + "?ref=" + CommitSHA);
	Фреймворк.ПроверитьРавенство(Результат[0].ИмяФайла, "test1.epf");
	Фреймворк.ПроверитьТип(Результат[0].ДвоичныеДанные, "ДвоичныеДанные");
	Фреймворк.ПроверитьРавенство(Результат[0].ОписаниеОшибки, "");
	Фреймворк.ПроверитьРавенство(Результат[1].ПутьКФайлуRAW, ПутьКФайлуRAW2 + "?ref=" + CommitSHA);
	Фреймворк.ПроверитьРавенство(Результат[1].ИмяФайла, "test2.epf");
	Фреймворк.ПроверитьТип(Результат[1].ДвоичныеДанные, "ДвоичныеДанные");
	Фреймворк.ПроверитьРавенство(Результат[1].ОписаниеОшибки, "");
	Фреймворк.ПроверитьВхождение(Результат[2].ОписаниеОшибки, "NOT_FOUND");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайлыКОтправкеПоДаннымЗапроса(Фреймворк) Экспорт

	// given
	URL = "http://mock-server:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";

	Константы.ИмяФайлаНастроекМаршрутизации.Установить(".ext-epf.json");	
	Константы.GitLabUserPrivateToken.Установить(Токен);
	Константы.ТаймаутGitLab.Установить(5);
	
	ПутьКФайлуRAW1 = "/api/v4/projects/1/repository/files/test1.epf/raw";
	ПутьКФайлуRAW2 = "/api/v4/projects/1/repository/files/test3.epf/raw";
	ПутьКФайлуRAW3 = "/api/v4/projects/1/repository/files/test9.epf/raw";
	CommitSHA1 = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	CommitSHA2 = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	CommitSHA3 = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	
	Мок = Обработки.MockServerClient.Создать();
	// нормальный файл 1
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW1).ПараметрСтрокиЗапроса("ref", CommitSHA1).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test1.epf").Тело("some_response_body")
	    );
	// нормальный файл 2
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW2).ПараметрСтрокиЗапроса("ref", CommitSHA2).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test3.epf").Тело("some_response_body")
	    );
	// пустой файл (без тела)
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьКФайлуRAW3).ПараметрСтрокиЗапроса("ref", CommitSHA3).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test9.epf")
	    );
	Мок = Неопределено;

	JSON = НСтр("ru = '{
				|  ""project"": {
				|    ""id"": 1,
				|    ""http_url"": """ + URL + "/root/external-epf.git""
				|  },
				|  ""commits"": [
				|    {
				|      ""id"": ""1b9949a21e6c897b3dcb4dd510ddb5f893adae2f"",
				|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
				|      ""added"": [
				|        "".ext-epf.json"",
				|        ""src/Внешняя Обработка 1.xml"",
				|        ""test3.epf""
				|      ],
				|      ""modified"": [
				|        ""src/Внешняя Обработка 1/Forms/Форма/Ext/Form.bin"",
				|        ""test1.epf""
				|      ],
				|      ""removed"": [
				|
				|      ]
				|    },
				|    {
				|      ""id"": ""ef886bb4e372250d8212387350f7e139cbe5a1af"",
				|      ""timestamp"": ""2020-07-21T09:22:30+00:00"",
				|      ""added"": [
				|        "".ext-epf.json"",
				|        ""src/Внешняя Обработка 3/Forms/Форма/Ext/Form.bin"",
				|        ""test3.epf""
				|      ],
				|      ""modified"": [
				|        ""src/Внешняя Обработка 1/Forms/Форма.xml"",
				|        ""test1.epf""
				|      ],
				|      ""removed"": [
				|
				|      ]
				|    },
				|    {
				|      ""id"": ""968eca170a80a5c825b0808734cb5b109eaedcd3"",
				|      ""timestamp"": ""2020-03-16T16:00:15+03:00"",
				|      ""added"": [
				|
				|      ],
				|      ""modified"": [
				|        ""src/Внешняя Обработка 3/Forms/Форма.xml"",
				|        ""test9.epf"",
				|        ""test3.epf""
				|      ],
				|      ""removed"": [
				|
				|      ]
				|    }
				|  ]
				|}'");
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	// when
	Результат = Gitlab.ПолучитьФайлыКОтправкеПоДаннымЗапроса( Справочники.ОбработчикиСобытий.ПустаяСсылка(), ДанныеЗапроса);

	// then
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 6);
	Фреймворк.ПроверитьРавенство(Результат[1].ПутьКФайлуRAW, ПутьКФайлуRAW1 + "?ref=" + CommitSHA1);
	Фреймворк.ПроверитьРавенство(Результат[1].CommitSHA, CommitSHA1);
	Фреймворк.ПроверитьРавенство(Результат[1].ИмяФайла, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[1].ПолноеИмяФайла, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[1].Операция, "modified");
	Фреймворк.ПроверитьРавенство(Результат[1].Дата, Дата(2020,07,21,09,22,31));
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[1].ДвоичныеДанные), "some_response_body");
	Фреймворк.ПроверитьРавенство(Результат[1].ОписаниеОшибки, "");
	
	Фреймворк.ПроверитьРавенство(Результат[0].ПутьКФайлуRAW, ПутьКФайлуRAW2 + "?ref=" + CommitSHA2);
	Фреймворк.ПроверитьРавенство(Результат[0].CommitSHA, CommitSHA2);
	Фреймворк.ПроверитьРавенство(Результат[0].ИмяФайла, "test3.epf");
	Фреймворк.ПроверитьРавенство(Результат[0].ПолноеИмяФайла, "test3.epf");
	Фреймворк.ПроверитьРавенство(Результат[0].Операция, "modified");
	Фреймворк.ПроверитьРавенство(Результат[0].Дата, Дата(2020,03,16,13,00,15)); // ""+03:00"
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[0].ДвоичныеДанные), "some_response_body");
	Фреймворк.ПроверитьРавенство(Результат[0].ОписаниеОшибки, "");
	
	Фреймворк.ПроверитьРавенство(Результат[2].ПутьКФайлуRAW, ПутьКФайлуRAW3 + "?ref=" + CommitSHA2);
	Фреймворк.ПроверитьРавенство(Результат[2].CommitSHA, CommitSHA2);
	Фреймворк.ПроверитьРавенство(Результат[2].ИмяФайла, "");
	Фреймворк.ПроверитьРавенство(Результат[2].ПолноеИмяФайла, "test9.epf");
	Фреймворк.ПроверитьРавенство(Результат[2].Операция, "modified");
	Фреймворк.ПроверитьРавенство(Результат[2].Дата, Дата(2020,03,16,13,00,15)); // ""+03:00"
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[2].ДвоичныеДанные), "");
	Фреймворк.ПроверитьВхождение(Результат[2].ОписаниеОшибки, НСтр("ru = 'Пустой файл.'"));
	
	Фреймворк.ПроверитьРавенство(Результат[3].ПолноеИмяФайла, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(Результат[4].ПолноеИмяФайла, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(Результат[5].ПолноеИмяФайла, ".ext-epf.json");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура GetMergeRequestsByQueryData(Фреймворк) Экспорт
	
	// given
	URL = "http://mock-server:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";

	Константы.GitLabUserPrivateToken.Установить(Токен);
	Константы.ТаймаутGitLab.Установить(5);
	
	ПутьMR = "/api/v4/projects/1/merge_requests";
	JSON = Нстр("ru = '[
				 |	{
				 |		""project_id"": 1,
				 |		""merge_commit_sha"": null,
				 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/4""
				 |	},
				 |	{
				 |		""project_id"": 1,
				 |		""merge_commit_sha"": ""c1775c33f82fcf22b3c2c4a5b4e95e430ef35d89"",
				 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/3""
				 |	},
				 |	{
				 |		""project_id"": 1,
				 |		""merge_commit_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
				 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/2""
				 |	},
				 |	{
				 |		""project_id"": 1,
				 |		""merge_commit_sha"": ""686109dffcee3e8ef51013f2e7702a8590eb5d73"",
				 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/1""
				 |	}
				 |]'");
	
	Мок = Обработки.MockServerClient.Создать();

	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьMR).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Тело(JSON)
	    );
	Мок = Неопределено;
	
	JSON = НСтр("ru = '{
				|  ""project"": {
				|    ""id"": 1,
				|    ""http_url"": """ + URL + "/root/external-epf.git""
				|  },
				|  ""commits"": [
				|    {
				|      ""id"": ""1b9949a21e6c897b3dcb4dd510ddb5f893adae2f"",
				|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
				|      ""added"": [
				|        "".ext-epf.json"",
				|        ""src/Внешняя Обработка 1.xml"",
				|        ""test3.epf""
				|      ],
				|      ""modified"": [
				|        ""src/Внешняя Обработка 1/Forms/Форма/Ext/Form.bin"",
				|        ""test1.epf""
				|      ],
				|      ""removed"": [
				|
				|      ]
				|    }
				|  ]
				|}'");
				
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	QueryData = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);
	
	// when
	Результат = Gitlab.GetMergeRequestsByQueryData( QueryData );
	
	// then
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 4);
	Фреймворк.ПроверитьРавенство(Результат[0].Количество(), 3);
	Фреймворк.ПроверитьРавенство(Результат[0].Get("project_id"), 1);
	Фреймворк.ПроверитьРавенство(Результат[0].Get("web_url"), "http://gitlab/root/external-epf/-/merge_requests/4");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ОписаниеФайлов(Фреймворк) Экспорт

	// given	
	// when
	Результат = Gitlab.ОписаниеФайлов();
	// then
	Фреймворк.ПроверитьРавенство(Результат.Колонки.ПутьКФайлуRAW.Имя, "ПутьКФайлуRAW");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.ИмяФайла.Имя, "ИмяФайла");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.ПолноеИмяФайла.Имя, "ПолноеИмяФайла");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.ДвоичныеДанные.Имя, "ДвоичныеДанные");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.Операция.Имя, "Операция");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.Дата.Имя, "Дата");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.CommitSHA.Имя, "CommitSHA");
	Фреймворк.ПроверитьРавенство(Результат.Колонки.ОписаниеОшибки.Имя, "ОписаниеОшибки");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПутьКФайлуRAW(Фреймворк) Экспорт
	
	// given
	Эталон = "/api/v4/projects/1/repository/files/%D0%B0%2F%D0%B1%2F%D0%B2/raw?ref=0123456789";
	// when
	Результат = Gitlab.ПутьКФайлуRAW(1, "а/б/в", "0123456789");
	//then
	Фреймворк.ПроверитьРавенство(Результат, Эталон);
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПереченьОперацийНадФайлами(Фреймворк) Экспорт

	// when	
	Результат = GitlabПовтИсп.ПереченьОперацийНадФайлами();
	// then
	Фреймворк.ПроверитьРавенство(Результат[0], "added");
	Фреймворк.ПроверитьРавенство(Результат[1], "modified");
	Фреймворк.ПроверитьРавенство(Результат[2], "removed");
	
КонецПроцедуры

#EndRegion
