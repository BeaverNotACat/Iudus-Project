extends KinematicBody2D

#Константные значения для физики
export var ACCELERATION = 800
export var MAX_SPEED = 150
export var FRICTION = 1000
export var DASH_SPEED = 10000
export var DASH_LENGHT = 0.2
export var MELEE_CHARGING_TIME = 1

#Вспомогательные глобальные переменные
var state = MOVE
var velocity = Vector2.ZERO
var aim_direction = Vector2.ZERO
var dash_direction #ОТ этой надо избавится (Хотя я не придумал как сделать лучше, так что пусть будет~~)

#булевы перменные в помощь машине состояний
var is_charged : bool = false

#Список состояний
enum{
	MOVE,
	DASH
	ATTACK_PREPARE
}

#Импорт узлов
onready var dash_timer = $Dash_timer
onready var attack_timer = $Attack_timer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

#соединение переменных с узлами и добавление к сигналов
func _ready():
	dash_timer.connect("timeout", self, "_dash_timer_timeout")
	attack_timer.connect("timeout", self, "_attack_timer_timeout")

#Лоховская машина состояний(Для более продвинутой не хватило мозгов)
func _physics_process(delta):
	match state:
		MOVE:
			move_character(delta)
			get_dash_input()
			get_attack_pressed()
			collide()
		DASH:
			dash(delta)
			collide()
		ATTACK_PREPARE:
			move_character(delta)
			get_dash_input()
			get_attack_released()
			collide()
	#Дебаг
		#print(velocity)
		#print(aim_direction)
		#print(position)
		#print(state)

########################
#Получаем направление движение
func get_move_direction():
	var motion_input = Vector2.ZERO
	motion_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	motion_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	motion_input = motion_input.normalized()
	return(motion_input)

#Получаем направление прицеливания
#Если goal 1, то выводим градусы, иначе единичный вектор
func get_aim_direction(goal):
	var mouse_pos = get_global_mouse_position()
	aim_direction = global_position.direction_to(mouse_pos)
	aim_direction = aim_direction.normalized()
	if (goal == 0):
		return(aim_direction)
	else:
		return(aim_direction.angle())

#Меняем состояние и начинаем дейсвие, если соблюдены условия
func get_dash_input():
	if Input.is_action_just_pressed("dash"):
		state = DASH
		dash_timer.start(DASH_LENGHT)
		dash_direction = get_aim_direction(0)
		velocity = Vector2.ZERO

#Узнаем ЗАЖАТА ли кнопка, если да то начинаем зарядку сильной атаки по таймеру
func get_attack_pressed():
	if Input.is_action_just_pressed("melee_attack"):
		state = ATTACK_PREPARE
		attack_timer.start(MELEE_CHARGING_TIME)

#Узнаем отжата ли кнопка, если если сильная атака успела зарядится то сильную, иначе
func get_attack_released():
	if Input.is_action_just_released("melee_attack") && state == ATTACK_PREPARE:
		if is_charged == true:
			charged_meelee_attack()
		else:
			light_melee_attack()
########################

#Двигаем спрайт спрайт по физике плюс обрабатываем коллизии
func move_character(delta):
	var move_direction = get_move_direction()
	if move_direction != Vector2.ZERO:
		
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Run/blend_position", move_direction)
		animation_state.travel("Run")
		
		velocity = velocity.clamped(MAX_SPEED)
		velocity = velocity.move_toward(MAX_SPEED * move_direction, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.clamped(MAX_SPEED)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

#Двигаем спрайт со скоростью дэша
func dash(delta):
	velocity += DASH_SPEED * dash_direction * delta

#Пока пропустим
func light_melee_attack():
	state = MOVE
#Пока пропустим x2
func charged_meelee_attack():
	state = MOVE

#обработка коллизий внесенная в отдельную функцию
func collide():
	velocity = move_and_slide(velocity)

#Возвращаемся в стандартное состояние, по истечениюю таймера
func _dash_timer_timeout():
	state = MOVE

#По истечению таймера считаем что сильная мили атка зарядилась
func _attack_timer_timeout():
	is_charged = true
