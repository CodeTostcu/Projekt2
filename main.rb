=begin
  File: main.rb
  Author: Kaan Önal
  Date: 2025-05-13
  Description: This program creates a parkour with diffrent levels and obstacles
=end

require 'ruby2d'

#Background, characters and objects
background = Image.new('background.jpg', width: 900, height: 485)

checkpoint = Image.new('checkpoint.webp', width: 50, height: 50, x: 510, y: 62)

killergooses = [Image.new('killer.png', x: 120, y: 66, width: 40, height: 40)]

character = Sprite.new(
  'character.png',   
  x: 10, y: 300,    
  width: 36, height: 36,        
  clip_width: 16, clip_height: 16, 
  clip_y: 16.01,  
  animations: {
    walk_right: 6..12, 
  }
)

ground = Rectangle.new(
  color: 'green',
  x: 0,
  y: 400,
  width: 700,  
  height: 100,  
)

#Placment and measures for platforms/killerplatforms
platforms = [
  Rectangle.new(x: 10, y: 350, width: 50, height: 10, color: 'yellow'),
  Rectangle.new(x: 90, y: 300, width: 40, height: 10, color: 'brown'),
  Rectangle.new(x: 260, y: 350, width: 30, height: 10, color: 'brown'),
  Rectangle.new(x: 360, y: 350, width: 30, height: 10, color: 'brown'),
  Rectangle.new(x: 360, y: 260, width: 30, height: 10, color: 'brown'),
  Rectangle.new(x: 460, y: 300, width: 30, height: 10, color: 'brown'),
  Rectangle.new(x: 260, y: 260, width: 80, height: 10, color: 'brown'),
  Rectangle.new(x: 120, y: 210, width: 80, height: 10, color: 'brown'),
  Rectangle.new(x: 120, y: 210, width: 80, height: 10, color: 'brown'),
  Rectangle.new(x: 50, y: 160, width: 40, height: 10, color: 'brown'),
  Rectangle.new(x: 120, y: 100, width: 300, height: 10, color: 'brown'),
  Rectangle.new(x: 500, y: 100, width: 50, height: 10, color: 'yellow'),
]

killerplatforms = [
  Rectangle.new(x: 295, y: 250, width: 10, height: 10, color: 'red'),
  Rectangle.new(x: 155, y: 200, width: 10, height: 10, color: 'red'),
  Rectangle.new(x: 160, y: 90, width: 10, height: 10, color: 'red'),
  Rectangle.new(x: 260, y: 90, width: 10, height: 10, color: 'red'),
  Rectangle.new(x: 360, y: 90, width: 10, height: 10, color: 'red'),
]

#Varibal to the physics in the game
Walk_speed = 2
jump_power = -5
up = "w"
left = "a"
right = "d"

velocity_y = 0
gravity = 0.2
max_fall_speed = 5 
on_ground = false
current_platform = nil
level = 1

#Collsion function checks 
def check_collision?(character, platform)
  character.x + character.width > platform.x &&  
  character.x < platform.x + platform.width &&
  character.y + character.height > platform.y &&
  character.y < platform.y + platform.height
end


def check_killer_collision?(character, killer_platform)
  character.x + character.width > killer_platform.x &&
  character.x < killer_platform.x + killer_platform.width &&
  character.y + character.height > killer_platform.y &&
  character.y < killer_platform.y + killer_platform.height
end

#Movment of the character
on :key_held do |event|
  case event.key
  when up
    if on_ground
      velocity_y = jump_power  
      on_ground = false
    end

  when left
    character.play animation: :walk_right, loop: true, flip: :horizontal
    character.x -= Walk_speed if character.x > 0  
  when right
    character.play animation: :walk_right, loop: true  
    character.x += Walk_speed if character.x < (Window.width - character.width)  
  end
end

on :key_up do |event|
  character.stop
end

#The movment variables as well as the level variabel
direction_y = 0.5
direction_x = 1

level_2 = { y: 100, x: 500 }

a = 1
time = 0

#The game loop
update do
  velocity_y += gravity unless on_ground  

  velocity_y = [velocity_y, max_fall_speed].min

  character.y += velocity_y

  time += 1

  on_ground = false
  current_platform = nil

#If statment regarding platforms movment 
  if platforms[1].y <= 280
    direction_y = direction_y * -1
  elsif platforms[1].y >= 360
    direction_y = direction_y * -1
  end

#If statment regarding killergoose movment
  if killergooses[0].x <= 100
    direction_x = direction_x * -1
  elsif killergooses[0].x >= 390
    direction_x = direction_x * -1
  end
  
  killergooses[0].x += direction_x

  platforms[1].y += direction_y
  platforms[9].y += direction_y

#The transparant variabels/functions
  index = [4,5].sample 
  platforms[index].color = [1, 0.5, 0.2, a]
  

  a = Math.sin(time * 0.005).abs

#The platform collisons 
  platforms.each do |platform|
    if platform == platforms[index] && a <= 0.6
      next
    end

    if check_collision?(character, platform)
      if character.y + character.height - velocity_y <= platform.y 
        character.y = platform.y - character.height  
        velocity_y = 0  
        on_ground = true
        current_platform = platform
      elsif platform == platforms[1] || platform == platforms[9]
        character.y = platform.y - character.height - 0.5
      elsif character.y < platform.y + platform.height  
        character.y = platform.y + platform.height
        velocity_y = 0
      end 

#The collsions with the killer platforms/objects
      killerplatforms.each do |killer_platform|
        if check_killer_collision?(character, killer_platform)
          character.x = 10
          character.y = 300
          velocity_y = 0     
          on_ground = true  
        end
      end

      killergooses.each do |killer_goose|
        if check_killer_collision?(character, killer_goose)
          character.x = 10
          character.y = 300
          velocity_y = 0     
          on_ground = true  
        end
      end
    end
  end

#If statment to reset position when falling down trough the ground
  if character.y >= 395
    character.x = 10
    character.y = 300
    velocity_y = 0
    on_ground = true
  end 

#The transition to level 2
  if character.y + character.height - velocity_y <= level_2[:y] &&  character.x >= level_2[:x] && character.x <= level_2[:x] + 50 && level == 1
    level = 2
    
        
    Window.clear  

    
#Background, characters, platforms and objects for level 2
    background2 = Image.new('background2.jpg', width: 700, height: 420)

    checkpoint2 = Image.new('checkpoint.webp', width: 50, height: 50, x: 510, y: 62)

    killergooses2 = [Image.new('killer.png', x: 120, y: 66, width: 40, height: 40)]

    character = Sprite.new(
    'character.png',   
    x: 10, y: 300,    
    width: 36, height: 36,        
    clip_width: 16, clip_height: 16, 
    clip_y: 16.01,  
    animations: {
      walk_right: 6..12, 
    }
  )

  ground2 = Rectangle.new(
    color: [0, 0, 139, 1.0],
    x: 0,
    y: 400,
    width: 700,  
    height: 100,  
  )

  platforms2 = [
    Rectangle.new(x: 10, y: 350, width: 50, height: 10, color: 'yellow'),
    Rectangle.new(x: 90, y: 300, width: 40, height: 10, color: 'blue'),
    Rectangle.new(x: 260, y: 350, width: 120, height: 10, color: 'blue'),
    Rectangle.new(x: 360, y: 350, width: 30, height: 10, color: 'blue'),
    Rectangle.new(x: 360, y: 260, width: 30, height: 10, color: 'blue'),
    Rectangle.new(x: 440, y: 220, width: 30, height: 10, color: 'blue'),
    Rectangle.new(x: 280, y: 210, width: 60, height: 10, color: 'blue'),
    Rectangle.new(x: 180, y: 210, width: 80, height: 10, color: 'blue'),
    Rectangle.new(x: 220, y: 210, width: 60, height: 10, color: 'blue'),
    Rectangle.new(x: 50, y: 160, width: 40, height: 10, color: 'blue'),
    Rectangle.new(x: 120, y: 100, width: 300, height: 10, color: 'blue'),
    Rectangle.new(x: 500, y: 100, width: 50, height: 10, color: 'yellow'),
    Rectangle.new(x: 440, y: 300, width: 30, height: 10, color: 'blue'),
    
  ]

  killerplatforms2 = [
    Rectangle.new(x: 280, y: 340, width: 10, height: 10, color: 'red'),
    Rectangle.new(x: 340, y: 340, width: 10, height: 10, color: 'red'),
    Rectangle.new(x: 150, y: 90, width: 10, height: 10, color: 'red'),
    Rectangle.new(x: 220, y: 90, width: 10, height: 10, color: 'red'),
    Rectangle.new(x: 290, y: 90, width: 10, height: 10, color: 'red'),
    Rectangle.new(x: 360, y: 90, width: 10, height: 10, color: 'red'),

  ]
  
#The platform collisons for level 2
  def check_collision?(character, platform2)
    character.x + character.width > platform2.x &&  
    character.x < platform2.x + platform2.width &&
    character.y + character.height > platform2.y &&
    character.y < platform2.y + platform2.height
  end

#The killerplatform collisons for level 2
  def check_killer_collision?(character, killer_platform2)
    character.x + character.width > killer_platform2.x &&
    character.x < killer_platform2.x + killer_platform2.width &&
    character.y + character.height > killer_platform2.y &&
    character.y < killer_platform2.y + killer_platform2.height
  end


  platforms = platforms2 #updated layout on the platform 
  killergooses = killergooses2 #updated layout on the killergoose 
  killerplatforms = killerplatforms2 #updated layout on the killerplatform 

  end

  #The transition to level 3
  if character.y + character.height - velocity_y <= level_2[:y] &&  character.x >= level_2[:x] && character.x <= level_2[:x] + 50 && level == 2
    level = 3
    Window.clear

    background3 = Image.new('winner.jpg', width: 650, height: 550)
    
  end 
end



show
