default_color = {222/255, 222/255, 222/255}
background_color = {16/255, 16/255, 16/255}
ammo_color = {123/255, 200/255, 164/255}
boost_color = {76/255, 195/255, 217/255}
hp_color = {241/255, 103/255, 69/255}
skill_point_color = {255/255, 198/255, 93/255}


------------------------------------
--ATTACK TYPES
------------------------------------

attacks = {
    ['Neutral'] = {cooldown = 0.24, ammo = 0, abbreviation = 'N',  color = default_color},
	['Double']  = {cooldown = 0.32, ammo = 2, abbreviation = '2',  color = ammo_color},
	['Triple']  = {cooldown = 0.32, ammo = 3, abbreviation = '3',  color = boost_color},
	['Rapid']   = {cooldown = 0.12, ammo = 1, abbreviation = 'R',  color = default_color},
	['Spread']  = {cooldown = 0.16, ammo = 1, abbreviation = 'RS', color = default_color, rnd_color = true},
	['Side']    = {cooldown = 0.32, ammo = 2, abbreviation = 'Si', color = boost_color},
	['Homing']  = {cooldown = 0.56, ammo = 4, abbreviation = 'H', color = skill_point_color, rnd_color = true},
	['Blast'] = {cooldown = 0.64, ammo = 6, abbreviation = 'W', color = default_color},
	['Spin'] = {cooldown = 0.32, ammo = 2, abbreviation = 'Sp', color = hp_color},
	['Flame'] = {cooldown = 0.048, ammo = 0.4, abbreviation = 'F', color = skill_point_color},
	['Bounce'] = {cooldown = 0.32, ammo = 4, abbreviation = 'Bn', color = default_color, rnd_color = true},
	['2Split'] = {cooldown = 0.32, ammo = 3, abbreviation = '2S', color = ammo_color},
	['4Split'] = {cooldown = 0.4, ammo = 4, abbreviation = '4S', color = boost_color},
	['Lightning'] = {cooldown = 0.2, ammo = 8, abbreviation = 'Li', color = default_color},
	['Explode'] = {cooldown = 0.6, ammo = 4, abbreviation = 'E', color = hp_color},
	['Laser'] = {cooldown = 0.8, ammo = 6, abbreviation = 'La', color = hp_color}
}

table_binds = {
	'Double',
	'Triple',
	'Rapid',
	'Spread',
	'Side',
	'Homing',
	'Blast',
	'Spin',
	'Flame',
	'Bounce',
	'2Split',
	'4Split',
	'Lightning',
	'Explode',
	'Laser'
}

enemies = {'Rock', 'Shooter'}