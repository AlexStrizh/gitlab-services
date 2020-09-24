# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: GitLabServices.Tests.Тест_ПолучателиСервер
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

@OnServer
Сценарий: ПередачаДвоичныхДанныхБезПараметровДоставкиОтсутствуютПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиОтсутствуютПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхБезПараметровДоставкиЕстьПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиЕстьПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхОшибка403ForbiddenОтсутствуютПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхОшибка403ForbiddenОтсутствуютПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхОшибка403ForbiddenЕстьПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхОшибка403ForbiddenЕстьПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанных200OkОтсутствуютПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанных200OkОтсутствуютПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанных200OkЕстьПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанных200OkЕстьПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхБезПараметровДоставкиВФоне
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиВФоне(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхВФонеОдинФайл200OkЕстьПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхВФонеОдинФайл200OkЕстьПараметрыСобытия(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхВФонеТриФайла200OkЕстьПараметрыСобытия
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхВФонеТриФайла200OkЕстьПараметрыСобытия(Контекст());' |