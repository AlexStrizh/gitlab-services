# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: GitLabServices.Tests.Тест_ПередачаДанныхСервер
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

@OnServer
Сценарий: СервисПолучателяДоступен
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПередачаДанныхСервер.СервисПолучателяДоступен(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанных
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПередачаДанныхСервер.ПередачаДвоичныхДанных(Контекст());' |

@OnServer
Сценарий: ПередачаДвоичныхДанныхВФоне
	И я выполняю код встроенного языка на сервере
	| 'Тест_ПередачаДанныхСервер.ПередачаДвоичныхДанныхВФоне(Контекст());' |