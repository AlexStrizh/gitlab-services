# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: GitLabServices.Tests.Тест_HTTPСервисыКлиент
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

Сценарий: Тест_ServicesGET
	И я выполняю код встроенного языка
	| 'Тест_HTTPСервисыКлиент.Тест_ServicesGET(Контекст());' |

Сценарий: Тест_WebhooksPOST
	И я выполняю код встроенного языка
	| 'Тест_HTTPСервисыКлиент.Тест_WebhooksPOST(Контекст());' |