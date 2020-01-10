#Использовать logos
#Использовать ".\..\..\..\core"

Перем Лог;
Перем ФайлНастроек;
Перем КомандыПлагина;
Перем КонфигураторХранилища;
Перем НомерВерсииХранилища;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.0.1";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 1;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Выполнение платформенных проверок и выгрузка результатов в SonarQube";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "platform8check_plugin";
КонецФункции

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.platform8check_plugin";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

#Область Подписка_на_получение_параметров_выполнения

// Вызывается при передаче параметров в МенеджерСинхронизации 
//
// Параметры:
//   ПараметрыПодписчиков - Объект.ПараметрыПодписчиков - ссылка на класс ПараметрыПодписчиков
// 
// Объект <ПараметрыПодписчиков> реализовывает публичные функции:
// * Функция <Параметр>
// 		Получает и возвращает значение из индекса параметров
//
// 		Параметры:
//   	  * СтрокаИмениПараметра - Строка - имя параметра допустимо указание нескольких имен к параметру через пробел
//                              		  Например, "config --config -c c"
//   	  * ЗначениеПоУмолчанию  - Произвольный - возвращаемое значение в случае отсутствия параметра после получения из индекса
// 		Возвращаемое значение:
//   	  Строка, Число, Булево, Массив, Соответствие, Неопределено - значение параметра
// * Функция <ПолучитьПараметры> 
// 		Возвращает используемый индекс параметров 
//
// 		Возвращаемое значение:
//   	  Соответствие - соответствие ключей и значение параметров
//
// Примеры: 
//   ```
//   
//   ОтправлятьМетки = ПараметрыПодписчиков.Параметр("push --push P ОтправлятьМетки", Ложь);
//
//   ```
Процедура ПриПолученииПараметров(ПараметрыПодписчиков) Экспорт

	ФайлНастроек = ПараметрыКоманды.Параметр("v8check", "");

	Если НЕ ПустаяСтрока(ФайлНастроек)  Тогда
		Лог.Информация("Установлен файл настроек платформенной проверки <%1>", ФайлНастроек);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область Подписки_на_регистрацию_команд_приложения

// Вызывается при регистрации команды приложения
//
// Параметры:
//   ИмяКоманды - Строка - имя регистрируемой команды 
//   КлассРеализации - Объект.КомандаПриложения - ссылка на класс <КомандаПриложения>
//
Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	КлассРеализации.Опция("v8check", "", СтрШаблон("[*v8check] имя файла настроек платформенной проверки"))
						.ТСтрока()
						.ВОкружении("GITSYNC_PLATFORM8CHECK");

КонецПроцедуры

#КонецОбласти

#Область Подписки_на_начало_и_окончания_выполнения

// Вызывается после завершения работы менеджера синхронизации
//
// Параметры:
//   ПутьКХранилищу - Строка - полный путь к хранилищу конфигурации 
//   КаталогРабочейКопии - Строка - полный путь к рабочему каталогу копии
//
Процедура ПослеОкончанияВыполнения(ПутьКХранилищу, КаталогРабочейКопии) Экспорт

	ВыполнитьПлатформеннуюПроверку(КаталогРабочейКопии);

КонецПроцедуры

#КонецОбласти

#Область Подписки_на_начало_и_окончания_выгрузки_версии_конфигурации

// <Описание процедуры>
//
// Параметры:
//   Конфигуратор - <Тип.Вид> - <описание параметра>
//   КаталогРабочейКопии - <Тип.Вид> - <описание параметра>
//   ПутьКХранилищу - <Тип.Вид> - <описание параметра>
//   НомерВерсии - <Тип.Вид> - <описание параметра>
//
Процедура ПослеОкончанияВыгрузкиВерсииХранилищаКонфигурации(
	Конфигуратор, КаталогРабочейКопии, ПутьКХранилищу, НомерВерсии) Экспорт

	КонфигураторХранилища = Конфигуратор;
	КаталогИсходныхКодов = КаталогРабочейКопии;
	НомерВерсииХранилища = НомерВерсии;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыФункции

Процедура ВыполнитьПлатформеннуюПроверку(КаталогИсходныхКодов)

	Если КонфигураторХранилища = Неопределено Тогда
		Сообщить("Не было выгрузки новых версий из хранилища");
		Возврат;
	Конецесли;

	Если ФайлНастроек = Неопределено Тогда
		Сообщить("Не задан файл настроек платформенной проверки");
		Возврат;
	КонецЕсли;

	НастройкиПроверки = ЗагрузитьНастройкиJSON();

	МенеджерПлатформенныхПроверок = Новый МенеджерПлатформенныхПроверок();
	МенеджерПлатформенныхПроверок.КонфигураторБазыИсточника(КонфигураторХранилища);
	МенеджерПлатформенныхПроверок.КаталогИсходныхКодов(КаталогИсходныхКодов);

	Если Настройки.Свойство("ВремяОжидания") Тогда
		МенеджерПлатформенныхПроверок.ВремяОжидания(Настройки.ВремяОжидания);
	КонецЕсли;
	Если Настройки.Свойство("МаксимальноеВремяОжидания") Тогда
		МенеджерПлатформенныхПроверок.МаксимальноеВремяОжидания(Настройки.МаксимальноеВремяОжидания);
	КонецЕсли;
	
	Для Каждого КлючиПлатформеннойПроверки Из Настройки.Ключи Цикл
		МенеджерПроверок.НачатьПроверку(КлючиПлатформеннойПроверки);
	КонецЦикла;

	МенеджерПроверок.ЗавершитьВсеПроверки();
	
	ГенераторОтчета = Новый ГенераторОтчетaSonarQube();
	ГенераторОтчета.ВыгрузитьОшибкиВФайл(МенеджерПроверок.ТаблицаОшибок(), Настройки.Проект, Настройки.ФайлSonarQube);

КонецПроцедуры

Функция ЗагрузитьНастройкиJSON()

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.ОткрытьФайл(ФайлНастроек);

	Настройки = ПрочитатьJSON(ЧтениеJSON);

	Настройки = Новый Структура();
	Настройки.Вставить("ВремяОжидания", 5);
	Настройки.Вставить("МаксимальноеВремяОжидания", 5);
	Настройки.Вставить("Ключи", Новый Массив);
	Настройки.Ключи.Добавить("");
	Настройки.Ключи.Добавить("");
	Настройки.Вставить("Проект", "UH");
	Настройки.Вставить("ФайлSonarQube", "");

	Возврат Настройки;

КонецФункции

#КонецОбласти

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	
	ФайлНастроек = Неопределено;
	
КонецПроцедуры

Инициализация();