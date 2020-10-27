#Region Public

#Область Потоки

// Дополняет коллекцию элементом, значением которого является текст прочитанный из потока.
// 
// Параметры:
// 	Поток - Поток - поток из которого необходимо прочитать текст;
// 	Ключ - Строка - ключ элемента;
// 	Коллекция - Структура, Соответствие - коллекция, в которую добавляется элемент с текстом;
//			
Процедура ДополнитьКоллекциюТекстомИзПотока(Знач Поток, Знач Ключ, Коллекция) Экспорт
	
	Var ИсходныйТекст;
	Var ЧтениеТекста;

	Попытка
		
		Поток.Перейти( 0, ПозицияВПотоке.Начало );
		ЧтениеТекста = Новый ЧтениеТекста( Поток, КодировкаТекста.UTF8 );
		ИсходныйТекст = ЧтениеТекста.Прочитать();
		Коллекция.Вставить( Ключ, ИсходныйТекст );
		
	Исключение

		ЧтениеТекста.Закрыть();
		ВызватьИсключение;

	КонецПопытки;
	
	ЧтениеТекста.Закрыть();
	
КонецПроцедуры

#EndRegion 


#EndRegion