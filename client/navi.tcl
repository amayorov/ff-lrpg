package require Tcl 8.5

# Модуль включает в себя навигацию и работу с радаром

namespace eval navi {
    variable coords ;# Текущие координаты корабля, получаются по событию с сервера
    variable objects ;# Пары имя объекта -- координаты
}
