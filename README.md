#  Тестовое задание по iOS
Погода

1. Стартовый экран состоит из двух табов: на первом отображается карта, на втором - список городов.
    1. При тапе по карте устанавливается маркер и приложение загружает текущую погоду для 20 городов вокруг этого маркера.
    1. Загруженные города отображаются в виде маркеров (иконка должна отличаться от маркера-центра поиска) на карте.
    1. При тапе по маркеру появляется popup с информацией о текущей погоде.
1. При переключении на другую табу - отображается список загруженных городов, элемент списка состоит из названия города.
    1.При тапе по элементу списка - элемент списка увеличивает свою высоту и отображается текущая погода.
1. При повтороной загрузке городов ранее загруженная информация очищается.
---
- Стартовое положение на карте определяется местположением пользователя, в случае запрета пользователя на определение местоположения - г. Ростов-на-Дону.

## Приложение должно:
- обрабатывать поворот экрана
- работать с версии ios - 9
- Библиотека для работы с картами GoogleMaps
- Сервис погоды http://openweathermap.org/api
