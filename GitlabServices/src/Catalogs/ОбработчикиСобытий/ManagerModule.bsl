#Область ПрограммныйИнтерфейс

// Поиск элементов справочника по секретному ключу (token), не помеченные на удаление.
//
// Параметры:
// 	Token - Строка - секретный ключ (token);
//
// Возвращаемое значение:
// 	Массив из СправочникСсылка.ОбработчикиСобытий - найденные элементы справочника (пустой массив, если не найдено); 
//
Функция НайтиПоСекретномуКлючу( Знач Token ) Экспорт
	
	Перем Запрос;
	Перем Результат;
	
	Результат = Новый Массив();
	
	Если ( ТипЗнч(Token) <> Тип("Строка") ИЛИ ПустаяСтрока(Token) ) Тогда
		
		Возврат Результат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр( "СекретныйКлюч", Token );
	Запрос.Текст = 	"ВЫБРАТЬ
	               	|	ОбработчикиСобытий.Ссылка КАК Ссылка
	               	|ИЗ
	               	|	Справочник.ОбработчикиСобытий КАК ОбработчикиСобытий
	               	|ГДЕ
	               	|	НЕ ОбработчикиСобытий.ПометкаУдаления
	               	|	И ОбработчикиСобытий.СекретныйКлюч = &СекретныйКлюч";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку( "Ссылка" );
	
КонецФункции

// TODO рефакторинг

// Загружает историю событий из журнала регистрации в табличную часть элемента справочника.
// Записи в журнале отбираются по параметрам отбора (См. глобальный контекст ЗагрузитьИсториюСобытийВходящихПараметров).
// Данные дописываются (!), т.е. проверок на дубли не осуществляется.
// 
// Параметры:
// 	Ссылка - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника, куда необхоимо загрузить данные;
// 	ПараметрыОтбора - Структура - (См. глобальный контекст ЗагрузитьИсториюСобытийВходящихПараметров);
// 	ДобавленоЗаписей - Число - возвращаемый параметр, количество добавленных записей;
Процедура ЗагрузитьИсториюСобытий(Знач Ссылка, Знач ПараметрыОтбора, ДобавленоЗаписей) Экспорт
	
	Перем ДанныеЖурналаРегистрации;
	Перем ТекстСообщения;
	
	ЗагрузитьИсториюСобытийВходящихПараметров(Ссылка, ПараметрыОтбора);
	
	ДанныеЖурналаРегистрации = Новый ТаблицаЗначений;
	ВыгрузитьЖурналРегистрации(ДанныеЖурналаРегистрации, ПараметрыОтбора);
	
	Если ДанныеЖурналаРегистрации.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	// Заблокировать() не используем, так как операция загрузки истории
	// в приоритете над остальными интерактивными действиями пользователя.	
	Webhook = Ссылка.ПолучитьОбъект();
	
	ДобавленоЗаписей = 0;
	Webhook.ИсторияСобытий.Очистить();
	Для каждого ЗаписьЖурналаРегистрации Из ДанныеЖурналаРегистрации Цикл
		
		Событие = Логирование.ПреобразоватьСтрокуСобытияВСтруктуру(ЗаписьЖурналаРегистрации.Событие);

		Если Событие.Объект <> "ОбработчикиСобытий" Тогда
			Продолжить;
		КонецЕсли;

		НоваяЗаписьИстории = Webhook.ИсторияСобытий.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяЗаписьИстории, ЗаписьЖурналаРегистрации);
		ЗаполнитьЗначенияСвойств(НоваяЗаписьИстории, Событие);
		// TODO к удалению Перечисления.УровеньЖурналаРегистрации 
		НоваяЗаписьИстории.Уровень = Перечисления.УровеньЖурналаРегистрации[Строка(ЗаписьЖурналаРегистрации.Уровень)];
		
		ДобавленоЗаписей = ДобавленоЗаписей + 1;

	КонецЦикла;
	
	Попытка
		Webhook.Записать();
	Исключение
		
		ДополнительныеПараметры = Логирование.ДополнительныеДанные();
		ДополнительныеПараметры.Объект = Ссылка;
		ТекстСообщения = НСтр("ru = 'Ошибка переноса истории событий из журнала регистрации.'");
		Логирование.Ошибка("System.ИсторияСобытий",	ТекстСообщения, ДополнительныеПараметры );
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Ручной запуск отправки обработанных данных в фоне.
// 
// Параметры:
// 	Ссылка - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника, для которого запускается обработка данных;
// 	КлючЗапроса - РегистрСведенийКлючЗаписи.ОбработчикиСобытий - ключ записи на данные, которые должны быть отправлены;
Процедура ЗапуститьОбработкуДанныхВручную(Знач Ссылка, Знач КлючЗапроса) Экспорт
	
	Перем ДанныеТелаЗапроса;
	
	//ДанныеТелаЗапроса = РегистрыСведений.ДанныеОбработчиковСобытий.ПолучитьДанныеТелаЗапроса(КлючЗапроса);
	ДанныеТелаЗапроса = ОбработчикиСобытий.ЗагрузитьДанныеЗапроса( Ссылка, КлючЗапроса );
	СервисыGitLab.ЗапуститьОбработкуДанныхВФоне(Ссылка, ДанныеТелаЗапроса, Истина);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиПроведения

#КонецОбласти

#Область ОбработчикиСобытий

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗагрузитьИсториюСобытийВходящихПараметров(Знач Ссылка, Знач ПараметрыОтбора)
													
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"Справочники.Webhooks",
		"Ссылка",
		Ссылка,
		Тип("СправочникСсылка.ОбработчикиСобытий"));
		
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"Справочники.Webhooks",
		"ПараметрыОтбора",
		ПараметрыОтбора,
		Тип("Структура"));
	
КонецПроцедуры

#КонецОбласти