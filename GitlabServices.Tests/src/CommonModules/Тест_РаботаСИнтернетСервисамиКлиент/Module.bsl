#Область СлужебныйПрограммныйИнтерфейс

//@unit-test
Процедура Тест_ОписаниеСервисаСоответствуетЭталону(Фреймворк) Экспорт

	Тест_РаботаСИнтернетСервисамиСервер.УстановитьОбрабатыватьЗапросыВнешнегоХранилища(Истина);
	
	ОписаниеСервиса = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервиса("gitlab");
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.Свойство("name"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.Свойство("desc"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.Свойство("enabled"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.Свойство("templates"));
	Фреймворк.ПроверитьРавенство(ОписаниеСервиса.templates.Количество(), 2);
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].Свойство("name"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].Свойство("desc"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].Свойство("template"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].Свойство("methods"));
	Фреймворк.ПроверитьРавенство(ОписаниеСервиса.templates[0].methods.Количество(), 1);
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].methods[0].Свойство("name"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].methods[0].Свойство("desc"));
	Фреймворк.ПроверитьИстину(ОписаниеСервиса.templates[0].methods[0].Свойство("method"));
	
	Тест_РаботаСИнтернетСервисамиСервер.УстановитьОбрабатыватьЗапросыВнешнегоХранилища(Ложь);

КонецПроцедуры

// @unit-test
Процедура Тест_ОписаниеСервисаURL(Фреймворк) Экспорт
	
	//https://github.com/DoublesunRUS/ru.capralow.dt.unit.launcher/issues/20
	//URL = Фреймворк.ПолучитьСохраненноеЗначениеИзКонтекстаСохраняемого("МестоположениеСервисовИБРаспределителя");
	URL = "http://web/api/hs/gitlab";
	
	Фреймворк.ПроверитьЗаполненность(URL, "Нет URL (user_settings.json -> МестоположениеСервисовИБРаспределителя");
	Фреймворк.ПроверитьЛожь(ПустаяСтрока(URL), "URL не может быть пустым, проверьте user_settings.json.");
	
	BadURL = "йохохо";
	Шаблон = СтрШаблон("а = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(""%1"")", BadURL);
	Фреймворк.ПроверитьНеВыполнилось(Шаблон, "Ошибка работы с Интернет:   Couldn't resolve host name");

	BadURL = "";
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(BadURL);
	Фреймворк.ПроверитьТип(Ответ, "Неопределено", "Пустой адрес");

	BadURL = Новый Массив;
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(BadURL);
	Фреймворк.ПроверитьТип(Ответ, "Неопределено", "Неверный тип");
	
	BadURL = URL + "йохохо";
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(BadURL);
	Фреймворк.ПроверитьТип(Ответ, "Неопределено", "Ошибка в имени сервиса");
	
	BadURL = "http://www.example.com";
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(BadURL);
	Фреймворк.ПроверитьТип(Ответ, "Неопределено", "Ошибка преобразования тела ответа в коллекцию");
	
	BadURL = "http://www.example.com/NotFound";
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(BadURL);
	Фреймворк.ПроверитьТип(Ответ, "Неопределено", "Страница не найдена");

	// 200
	Ответ = Тест_РаботаСИнтернетСервисамиСервер.ОписаниеСервисаURL(URL + "/services");
	Фреймворк.ПроверитьИстину(Ответ.Свойство("Ответ"));
	Фреймворк.ПроверитьТип(Ответ.Ответ, "Структура", "Веб-сервис не отвечает.");
	Фреймворк.ПроверитьЗаполненность(Ответ.Ответ, "Ответ веб-сервиса не должен быть пустым.");
	Фреймворк.ПроверитьРавенство(Ответ.Ответ.КодСостояния, 200, "Веб-сервис отвечает, но с ошибкой.");

	Фреймворк.ПроверитьРавенство(Ответ.Количество(), 3);
	Фреймворк.ПроверитьИстину(Ответ.Свойство("Ответ"));
	Фреймворк.ПроверитьИстину(Ответ.Свойство("Данные"));
	Фреймворк.ПроверитьИстину(Ответ.Свойство("json"));
	Фреймворк.ПроверитьВхождение(Ответ.json, """version""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """services""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """enabled""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """templates""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """template""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """methods""");
	Фреймворк.ПроверитьВхождение(Ответ.json, """method""");	

КонецПроцедуры

#КонецОбласти