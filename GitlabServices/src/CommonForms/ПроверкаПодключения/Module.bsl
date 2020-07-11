#Область ОбработчикиСобытийФормы

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура Проверить(Команда)
	
	Перем Ответ;
	
	ЭтаФорма.JSON = "";
	
	Если НЕ ЭтоКорректныйАдрес() Тогда
		ВызватьИсключение НСтр("ru = 'Не указан адрес веб-сервиса.'");		
	КонецЕсли;
	
	Ответ = Новый Структура("СервисДоступен, СервисВключен, ТелоОтветаТекст", Ложь, Ложь, Неопределено);
	
	ПроверитьВебСервис(Адрес, Ответ);

	Если Ответ.ТелоОтветаТекст <> Неопределено Тогда
		ЭтаФорма.JSON = Ответ.ТелоОтветаТекст;
	КонецЕсли;

	ЭтаФорма.Результат = ФорматированныйТекстРезультатаПроверки(Ответ);
	 
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ЭтоКорректныйАдрес()
	Возврат НЕ ПустаяСтрока(ЭтаФорма.Адрес);
КонецФункции

&НаСервереБезКонтекста
Процедура ПроверитьВебСервис(Знач URL, Результат)
	
	Перем Ответ;
	Перем Сервисы;
	
	Ответ = РаботаСИнтернетСервисами.ОписаниеСервисаURL(URL);
	
	Если Ответ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Ответ.Ответ.КодСостояния <> 200 Тогда
		Возврат;
	КонецЕсли;
	
	Если Ответ = Неопределено ИЛИ НЕ Ответ.Свойство("Соответствие") Тогда
		Возврат;
	КонецЕсли;
			
	Сервисы = Ответ.Соответствие.Получить("services");
	Если Сервисы = Неопределено Тогда
		Результат.ТелоОтветаТекст = НСтр("ru = 'В теле ответа JSON отсутствует свойство ""services"".'"); 
		Возврат;		
	КонецЕсли;
	
	Результат.СервисДоступен = Истина;
	Результат.СервисВключен = Сервисы.Получить("enabled");
	Результат.ТелоОтветаТекст = СоответствиеВФорматированныйJSON(Ответ.Соответствие);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоответствиеВФорматированныйJSON(Знач Соответствие, Знач ПараметрыЗаписиJSON = Неопределено)
	
	Перем ЗаписьJSON;
	Перем ИмяФайла;
	
	Если ПараметрыЗаписиJSON = Неопределено Тогда
		ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(, Символы.Таб);		
	КонецЕсли;
			
	ЗаписьJSON = Новый ЗаписьJSON;
	
	ИмяФайла = ПолучитьИмяВременногоФайла();
	ЗаписьJSON.ОткрытьФайл(ИмяФайла, КодировкаТекста.UTF8, , ПараметрыЗаписиJSON);
	ЗаписатьJSON(ЗаписьJSON, Соответствие);
	ЗаписьJSON.Закрыть();
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(ИмяФайла, КодировкаТекста.UTF8);
	
	Результат = ТекстовыйДокумент.ПолучитьТекст();
	
	УдалитьФайлы(ИмяФайла);
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ФорматированныйТекстРезультатаПроверки(Знач Ответ)
	
	Перем Сообщения;
	
	Сообщения = Новый Массив;
	Если Ответ.СервисДоступен Тогда
		Сообщения.Добавить(Новый ФорматированнаяСтрока("Сервис доступен.", , WebЦвета.Зеленый));
		Если Ответ.СервисВключен Тогда
			Сообщения.Добавить(Новый ФорматированнаяСтрока(" Статус работы: включен.", , WebЦвета.Зеленый));
		Иначе
			Сообщения.Добавить(Новый ФорматированнаяСтрока(" Статус работы: выключен.", , WebЦвета.Красный));
		КонецЕсли;
	Иначе
		Сообщения.Добавить(Новый ФорматированнаяСтрока("Сервис недоступен.", , WebЦвета.Красный));
	КонецЕсли; 
	
	Возврат Новый ФорматированнаяСтрока(Сообщения);
	
КонецФункции

#КонецОбласти