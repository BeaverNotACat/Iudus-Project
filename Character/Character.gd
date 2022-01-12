extends KinematicBody2D

#Константные значения для физики
export var ACCELERATION = 25
export var MAX_SPEED = 150
export var FRICTION = 0.57
export var DASH_SPEED = 100
export var DASH_LENGHT = 0.2

#Вспомогательные глобальные переменные
var state = MOVE
var velocity = Vector2.ZERO
var aim_direction = Vector2.ZERO
var dash_direction #ОТ этой надо избавится (Хотя я не придумал как сделать лучше, так что пусть будет~~)

#Список состояний
enum{
	MOVE,
	DASH
	LIGHT_ATTACK
}

#Импорт узлов
onready var timer = $Timer

#соединение переменных с узлами и добавление к сигналов
func _ready():
	timer.connect("timeout", self, "_timer_timeout")

#Лоховская машина состояний(Для более продвинутой не хватило мозгов)
func _physics_process(delta):
	match state:
		MOVE:
			move_character(delta)
			get_action_input(delta)
		DASH:
			dash_state()
			get_action_input(delta)
	#Дебаг
	#print(velocity)
	#print(aim_direction)
	#print(position)

########################
#Получаем направление движение
func get_move_direction(_delta):
	var motion_input = Vector2.ZERO
	motion_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	motion_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	motion_input = motion_input.normalized()
	return(motion_input)

#Получаем направление прицеливания
#Если goal 1, то выводим градусы, иначе единичный вектор
func get_aim_direction(_delta, goal):
	var mouse_pos = get_global_mouse_position()
	aim_direction = global_position.direction_to(mouse_pos)
	aim_direction = aim_direction.normalized()
	if (goal == 0):
		return(aim_direction)
	else:
		return(aim_direction.angle())

#Меняем состояние и начинаем дейсвие, если соблюдены условия
func get_action_input(delta):
	if Input.is_action_just_pressed("dash") && state == MOVE:
		state = DASH
		timer.start(DASH_LENGHT)
		dash_direction = get_aim_direction(delta, 0)
########################

#Двигнаем спрайт спрайт по физике плюс обрабатываем коллизии
func move_character(delta):
	if get_move_direction(delta) != Vector2.ZERO:
		velocity = velocity.clamped(MAX_SPEED)
		velocity = velocity.move_toward(MAX_SPEED * get_move_direction(delta), ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
	velocity = move_and_slide(velocity)

#Двигаем спрайт со скоростью дэша
func dash_state():
	velocity += DASH_SPEED * dash_direction 
	velocity = move_and_slide(velocity)

#Возвращаемся в стандартное состояние, по истечениюю таймера
func _timer_timeout():
	state = MOVE
