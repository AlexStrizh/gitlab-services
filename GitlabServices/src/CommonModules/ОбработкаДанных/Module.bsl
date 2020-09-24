#Область ПрограммныйИнтерфейс

// Запускает задание по обработке данных, полученных из запроса сервера GitLab, либо запускает задание по ранее
// сохраненным данным из полученных ранее запросов.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	ОбрабатываемыеДанные - Соответствие, Строка - преобразованное в коллекцию тело запроса или "checkout_sha" ранее
// 													сохраненного запроса;
//
// Возвращаемое значение:
// 	Неопределено, ФоновоеЗадание - созданное ФоновоеЗадание или Неопределено, если были ошибки;
//
Функция НачатьЗапускОбработкиДанных( Знач ОбработчикСобытия, Знач ОбрабатываемыеДанные ) Экспорт
	
	Перем CheckoutSHA;
	Перем ПараметрыЗадания;
	Перем ПараметрыЛогирования;
	Перем Сообщение;
	Перем Результат;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );

	Сообщение = "";
	Результат = Неопределено;
	
	Если ( ТипЗнч(ОбрабатываемыеДанные) = Тип("Строка") ) Тогда
		
		CheckoutSHA = ОбрабатываемыеДанные;
		ДанныеЗапроса = Неопределено;
	
	ИначеЕсли ( ТипЗнч(ОбрабатываемыеДанные) = Тип("Соответствие") ) Тогда
		
		CheckoutSHA = ОбрабатываемыеДанные.Получить( "checkout_sha" );
		ДанныеЗапроса = ОбрабатываемыеДанные;
		
		Если ( CheckoutSHA = Неопределено ) Тогда
			
			Сообщение = НСтр( "ru = 'В обрабатываемых данных отсутствует checkout_sha.'" );
			
		КонецЕсли;

	Иначе
		
		Сообщение = НСтр( "ru = 'Неподдерживаемый формат обрабатываемых данных.'" );
		
	КонецЕсли;
	
	Если ( НЕ ПустаяСтрока(Сообщение) ) Тогда
	
		Логирование.Ошибка( "Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
		
		Возврат Результат;
	
	КонецЕсли;
	
	Если ( ЕстьАктивноеЗадание(CheckoutSHA) ) Тогда
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "фоновое задание уже запущено.", CheckoutSHA );
		Логирование.Предупреждение( "Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
		
		Возврат Результат;
		
	КонецЕсли;
	
	ПараметрыЗадания = Новый Массив();
	ПараметрыЗадания.Добавить( ПараметрыСобытия( ОбработчикСобытия, CheckoutSHA ) );
	ПараметрыЗадания.Добавить( ДанныеЗапроса );

	Попытка
		
		Результат = ФоновыеЗадания.Выполнить( "ОбработкаДанных.ОбработатьДанные",
												ПараметрыЗадания,
												CheckoutSHA,
												"Обработка данных" );
		
	Исключение
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "запуск задания обработки данных.", CheckoutSHA );
		Сообщение = Сообщение + Символы.ПС + ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		Логирование.Ошибка( "Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
		
	КонецПопытки;
 
	Возврат Результат;
											
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ОбработатьДанные( Знач ПараметрыСобытия, Знач ДанныеЗапроса ) Экспорт
	
	Перем ОтправляемыеДанные;
	Перем ПараметрыЛогирования;
	Перем Сообщение;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ПараметрыСобытия.ОбработчикСобытия );

	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "обработка данных...", ПараметрыСобытия.CheckoutSHA );
	Логирование.Информация( "Core.ОбработкаДанных.Начало", Сообщение, ПараметрыЛогирования );	
	
	ОтправляемыеДанные = Неопределено;
	ПодготовитьДанные( ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные );
	
	Если ( НЕ ЗначениеЗаполнено(ДанныеЗапроса) ИЛИ НЕ ЗначениеЗаполнено(ОтправляемыеДанные) ) Тогда
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "нет данных для отправки.", ПараметрыСобытия.CheckoutSHA );
		Логирование.Информация( "Core.ОбработкаДанных.Окончание", Сообщение, ПараметрыЛогирования );
		
		Возврат;
		
	КонецЕсли;
	
	ОтправляемыеДанные = Маршрутизация.РаспределитьОтправляемыеДанныеПоМаршрутам( ОтправляемыеДанные, ДанныеЗапроса );		
	ОтправитьДанныеПоМаршрутам( ПараметрыСобытия, ОтправляемыеДанные );

	Логирование.Информация( "Core.ОбработкаДанных.Окончание", Сообщение, ПараметрыЛогирования );	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПараметрыСобытия( Знач ОбработчикСобытия, Знач CheckoutSHA )
	
	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "ОбработчикСобытия", ОбработчикСобытия );
	Результат.Вставить( "CheckoutSHA", CheckoutSHA );
	
	Возврат Результат;
	
КонецФункции

Процедура ПодготовитьДанные( Знач ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные )

	Перем ОбработчикСобытия;
	Перем CheckoutSHA;
	Перем ПараметрыЛогирования;	
	Перем Сообщение;
	
	ОбработчикСобытия = ПараметрыСобытия.ОбработчикСобытия;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;

	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "подготовка данных к отправке.", CheckoutSHA );
	
	Логирование.Информация( "Core.ПодготовкаДанных.Начало", Сообщение, ПараметрыЛогирования );

	Если ( ДанныеЗапроса <> Неопределено ) Тогда
		
		ОтправляемыеДанные = Gitlab.ПолучитьФайлыКОтправкеПоДаннымЗапроса( ОбработчикСобытия, ДанныеЗапроса );
		Маршрутизация.ДополнитьЗапросНастройкамиМаршрутизации(ДанныеЗапроса, ОтправляемыеДанные );
		
		СохранитьДанные( ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные );
		
	Иначе

		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "загрузка ранее сохраненных данных.", CheckoutSHA );
		Логирование.Информация( "Core.ПодготовкаДанных", Сообщение, ПараметрыЛогирования );
				
		ЗагрузитьДанные( ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные );
		
	КонецЕсли;

	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "подготовка данных к отправке.", CheckoutSHA );
	Логирование.Информация( "Core.ПодготовкаДанных.Окончание", Сообщение, ПараметрыЛогирования );
	
КонецПроцедуры

Функция АктивныеЗадания( Знач Ключ )
	
	Перем ПараметрыОтбора;
	
	ПараметрыОтбора = Новый Структура( "Ключ, Состояние", Ключ, СостояниеФоновогоЗадания.Активно );

	Возврат ФоновыеЗадания.ПолучитьФоновыеЗадания( ПараметрыОтбора );
	
КонецФункции

Функция ЕстьАктивноеЗадание( Знач Ключ )
	
	Возврат ЗначениеЗаполнено( АктивныеЗадания(Ключ) );
	
КонецФункции

Процедура СообщитьОРезультатеЗагрузки( Знач ПараметрыСобытия, Знач Расшифровка, Знач Результат )
	
	Перем ОбработчикСобытия;
	Перем CheckoutSHA;
	Перем ПараметрыЛогирования;
	Перем Сообщение;
	
	ОбработчикСобытия = ПараметрыСобытия.ОбработчикСобытия;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;

	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	
	Если ( ЗначениеЗаполнено(Результат) ) Тогда
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "[" + Расшифровка +"]: загружено.", CheckoutSHA );
		Логирование.Информация( "Core.ПодготовкаДанных", Сообщение, ПараметрыЛогирования );
		
	Иначе
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "[" + Расшифровка +"]: не найдено.", CheckoutSHA );
		Логирование.Предупреждение( "Core.ПодготовкаДанных", Сообщение, ПараметрыЛогирования );
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СообщитьОРезультатеСохранения( Знач ПараметрыСобытия, Знач Расшифровка )
	
	Перем ПараметрыЛогирования;
	Перем Сообщение;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ПараметрыСобытия.ОбработчикСобытия );
	Сообщение = "[" + Расшифровка +"]: сохранено.";
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( Сообщение, ПараметрыСобытия.CheckoutSHA);
	Логирование.Информация( "Core.ПодготовкаДанных", Сообщение, ПараметрыЛогирования );
		
КонецПроцедуры

Процедура ЗагрузитьДанные( Знач ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные )
	
	Перем ОбработчикСобытия;
	Перем CheckoutSHA;
	
	ОбработчикСобытия = ПараметрыСобытия.ОбработчикСобытия;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;

	ДанныеЗапроса = ОбработчикиСобытий.ЗагрузитьДанныеЗапроса( ОбработчикСобытия, CheckoutSHA );
	СообщитьОРезультатеЗагрузки( ПараметрыСобытия, "данные запроса", ДанныеЗапроса );

	ОтправляемыеДанные = ОбработчикиСобытий.ЗагрузитьВнешниеФайлы( ОбработчикСобытия, CheckoutSHA );
	СообщитьОРезультатеЗагрузки( ПараметрыСобытия, "отправляемые данные", ОтправляемыеДанные );
	
КонецПроцедуры

Процедура СохранитьДанные( Знач ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные )
	
	Перем ОбработчикСобытия;
	Перем CheckoutSHA;
	
	ОбработчикСобытия = ПараметрыСобытия.ОбработчикСобытия;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;

	ОбработчикиСобытий.СохранитьДанныеЗапроса( ОбработчикСобытия, CheckoutSHA, ДанныеЗапроса );
	СообщитьОРезультатеСохранения( ПараметрыСобытия, "данные запроса" );
	
	ОбработчикиСобытий.СохранитьВнешниеФайлы( ОбработчикСобытия, CheckoutSHA, ОтправляемыеДанные );
	СообщитьОРезультатеСохранения( ПараметрыСобытия, "отправляемые данные" );
		
КонецПроцедуры

Процедура ОтправитьДанныеПоМаршрутам( Знач ПараметрыСобытия, Знач ОтправляемыеДанные )
	
	Перем ОбработчикСобытия;
	Перем CheckoutSHA;
	Перем ПараметрыЛогирования;
	Перем ПараметрыДоставки;
	Перем КлючФоновогоЗадания;
	Перем Сообщение;
	Перем ОтправляемыхФайлов;
	Перем ЗапущенныхЗаданий;
	
	ОбработчикСобытия = ПараметрыСобытия.ОбработчикСобытия;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	
	ПараметрыДоставки = НастройкаСервисов.ПараметрыПолучателя();
	
	ОтправляемыхФайлов = 0;
	ЗапущенныхЗаданий = 0; 
	
	Для каждого ОтправляемыйФайл Из ОтправляемыеДанные Цикл
		
		Если ( НЕ ПустаяСтрока(ОтправляемыйФайл.ОписаниеОшибки) ) Тогда
			
			Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "ошибка получения файла:", CheckoutSHA );
			Сообщение = Сообщение + Символы.ПС + ОтправляемыйФайл.ОписаниеОшибки;
			Логирование.Предупреждение( "Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
			
			Продолжить;
			
		КонецЕсли;

		ОтправляемыхФайлов = ОтправляемыхФайлов + 1;
		
		Для Каждого Адрес Из ОтправляемыйФайл.АдресаДоставки Цикл
			
			ПараметрыДоставки.Адрес = Адрес;
			
			КлючФоновогоЗадания = CheckoutSHA + "|" + Адрес + "|" + ОтправляемыйФайл.ИмяФайла;
				
			Если ( ЕстьАктивноеЗадание(КлючФоновогоЗадания) ) Тогда
				
				Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "фоновое задание уже запущено.", CheckoutSHA );
				Сообщение = Сообщение + Символы.ПС + "Ключ задания: " + КлючФоновогоЗадания;
				Логирование.Предупреждение( "Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
				
				Продолжить;
				
			КонецЕсли;
			
			ПараметрыЗадания = Новый Массив();
			ПараметрыЗадания.Добавить( ОтправляемыйФайл.ИмяФайла );
			ПараметрыЗадания.Добавить( ОтправляемыйФайл.ДвоичныеДанные );
			ПараметрыЗадания.Добавить( ПараметрыДоставки );
			ПараметрыЗадания.Добавить( ПараметрыСобытия );
			
			ФоновыеЗадания.Выполнить("Получатели.ОтправитьФайл",
															ПараметрыЗадания,
															КлючФоновогоЗадания,
															"Отправка файла");
															
			ЗапущенныхЗаданий = ЗапущенныхЗаданий + 1;
				
		КонецЦикла;
		
	КонецЦикла;
	
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "отправляемых файлов: " + ОтправляемыхФайлов, CheckoutSHA );
	Логирование.Информация("Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
	
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( "запущенных заданий: " + ЗапущенныхЗаданий, CheckoutSHA );
	Логирование.Информация("Core.ОбработкаДанных", Сообщение, ПараметрыЛогирования );
	
КонецПроцедуры

#КонецОбласти