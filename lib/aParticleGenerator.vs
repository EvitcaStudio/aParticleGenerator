#DEFINE MAX_PLANE 999999
GeneratedParticle : inherit [Particle]

#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

var LIBRARY_particleGenArray = []
var LIBRARY_particleArray = []
var LIBRARY_activeGenerators = []
const PARTICLE_GENERATOR_TICK_RATE = 10
const MAX_ELAPSED_MS = 100

Client
	onWindowFocus()
		foreach (var gen in LIBRARY_activeGenerators)
			if (gen.settings.pausable)
				gen.resume()

	onWindowBlur()
		foreach (var gen in LIBRARY_activeGenerators)
			if (gen.settings.pausable)
				gen.pause()

Diob
	function attachParticleGenerator(settings)
		// Create a particle generator
		var generator = createParticleGenerator(settings, this)
		// If you already have a particle generator assigned to this diob
		if (this.particleGenerator)
			// Generate some particles
			generator.generateParticles()
			// Send all particles created to this diob's particle generator's particle array
			this.particleGenerator.gendParticles.push(...generator.gendParticles)
			// collect the newly created particle generator, we no longer need it. When its collected, it is cleaned and its particle array not longer has elements pointing to this particle array.
			aRecycle.collect(generator, LIBRARY_particleGenArray)
			return
			// If you do not already have a particle generator attached to this diob, then attach it now.
		this.particleGenerator = generator
		// If this generator doesn't have a loop setting, then when it is complete, reset this diobs `particleGenerator` var, as well as reset the particle generator

function createParticleGenerator(settings, emitter)
	var generator = aRecycle.isInCollection('ParticleGenerator', 1, LIBRARY_particleGenArray, true)
	
	if (!settings)
		return generator

	generator.settings.sizeOverLifetime = BezierEasing(0, 0, 0.58, 1)
	generator.settings.speedOverLifetime = BezierEasing(0, 0, 0.58, 1)
	generator.settings.alphaOverLifetime = BezierEasing(0, 0, 0.58, 1)

	// Valid texture(s) for the particle to use
	var validTextures = Icon.getIconNames('particle_atlas')

	// Check if settings.number exists and checking if it is a number
	if (settings.number && Util.isNumber(settings.number))
		generator.settings.number = settings.number

	//Interface
	if (settings.interfaceInfo)
		generator.settings.interfaceInfo = settings.interfaceInfo

	// Plane
	if (settings.plane || settings.plane === 0)
		if (Util.isObject(settings.plane))
			if (Util.isNumber(settings.plane?.randomBetween[0]) && Util.isNumber(settings.plane?.randomBetween[1]))
				generator.settings.plane = settings.plane

		else if (Util.isNumber(settings.plane))
			generator.settings.plane = settings.plane

	// Loop
	if (!settings.loop)
		generator.settings.loop = false
	else
		generator.settings.loop = settings.loop
	// Pausable
	if (settings.pausable)
		generator.settings.pausable = true

	// Emitter
	if (emitter)
		generator.settings.emitter = emitter

	// Check if settings.duration exists and checking if it is a number
	if (settings.duration && Util.isNumber(settings.duration))
		generator.settings.duration = settings.duration

	// Check if settings.radius exists and checking if it is a number
	if (settings.radius && Util.isNumber(settings.radius))
		generator.settings.radius = settings.radius

	// Check if settings.texture exists
	if (settings.texture)
		// Checking if settings.texture is a valid texture, or if it has a type and its not a `Object`.
		if (validTextures.includes(settings.texture) || (settings.texture.type && settings.texture.baseType !== 'Object'))
			generator.settings.texture = settings.texture
		else if (Util.isArray(settings.texture))
			var invalid
			foreach (var t in settings.texture)
				if (validTextures.includes(t))
					continue
				invalid = true
			if (!invalid)
				generator.settings.texture = settings.texture
	else
		generator.settings.texture = ''

	// Check if settings.orientation exists and if it is a string
	if (settings.orientation && Util.isString(settings.orientation))
		generator.settings.orientation = settings.orientation

	// Check if settings.angleOverLifetime exists and checking if it is a number
	if (settings.angleOverLifetime || settings.angleOverLifetime === 0 && Util.isNumber(settings.angleOverLifetime))
		generator.settings.angleOverLifetime = settings.angleOverLifetime

	// Check if settings.alphaOverLifetime exists and checking if it is a function
	if (settings.alphaOverLifetime && Util.getVariableType(settings.alphaOverLifetime) === 'function')
		generator.settings.alphaOverLifetime = settings.alphaOverLifetime

	// Check if settings.colorOverLifetime exists and checking if it is string
	if (settings.colorOverLifetime && Util.isString(settings.colorOverLifetime))
		generator.settings.colorOverLifetime = settings.colorOverLifetime

	// Check if settings.sizeOverTime exists and checking if it is a function
	if (settings.sizeOverTime && Util.getVariableType(settings.sizeOverTime) === 'function')
		generator.settings.sizeOverTime = settings.sizeOverTime

	// Check if settings.speedOverTime exists and checking if it is a function
	if (settings.speedOverTime && Util.getVariableType(settings.speedOverTime) === 'function')
		generator.settings.speedOverTime = settings.speedOverTime

	// Check if settings.startColor exists
	if (settings.startColor)
		// If settings.startColor is a number
		if (Util.isString(settings.startColor))
			generator.settings.startColor = settings.startColor
		
		// If settings.startColor is a object
		else if (Util.isObject(settings.startColor))
			if (Util.isString(settings.startColor?.randomBetween[0]) && Util.isString(settings.startColor?.randomBetween[1]))
				generator.settings.startColor = settings.startColor
	
	// Check if settings.startLifetime exists
	if (settings.startLifetime || settings.startLifetime === 0)
		// If settings.startLifetime is a number
		if (Util.isNumber(settings.startLifetime))
			generator.settings.startLifetime = settings.startLifetime
		
		// If settings.startLifetime is a object
		else if (Util.isObject(settings.startLifetime))
			if (Util.isNumber(settings.startLifetime?.randomBetween[0]) && Util.isNumber(settings.startLifetime?.randomBetween[1]))
				generator.settings.startLifetime = settings.startLifetime

	// Check if settings.startAngle exists
	if (settings.startAngle || settings.startAngle === 0)
		// If settings.startAngle is a number
		if (Util.isNumber(settings.startAngle))
			generator.settings.startAngle = settings.startAngle
		
		// If settings.startAngle is a object
		else if (Util.isObject(settings.startAngle))
			if (Util.isNumber(settings.startAngle?.randomBetween[0]) && Util.isNumber(settings.startAngle?.randomBetween[1]))
				generator.settings.startAngle = settings.startAngle

	// Check if settings.startSize exists
	if (settings.startSize || settings.startSize === 0)
		// If settings.startSize is a number
		if (Util.isNumber(settings.startSize))
			generator.settings.startSize = settings.startSize
		
		// If settings.startSize is a object
		else if (Util.isObject(settings.startSize))
			if (Util.isNumber(settings.startSize?.randomBetween[0]) && Util.isNumber(settings.startSize?.randomBetween[1]))
				generator.settings.startSize = settings.startSize

	// Check if settings.startSpeed exists
	if (settings.startSpeed || settings.startSpeed === 0)
		// If settings.startSpeed is a number
		if (Util.isNumber(settings.startSpeed))
			generator.settings.startSpeed = settings.startSpeed
		
		// If settings.startSpeed is a object
		else if (Util.isObject(settings.startSpeed))
			if (Util.isNumber(settings.startSpeed?.randomBetween[0]) && Util.isNumber(settings.startSpeed?.randomBetween[1]))
				generator.settings.startSpeed = settings.startSpeed

	// Check if settings.startAlpha exists and checking if it is a number or a string, if it is a string it must be === to'random'
	if (settings.startAlpha || settings.startAlpha === 0)
		if (Util.isNumber(settings.startAlpha) || Util.isString(settings.startAlpha) && settings.startAlpha === 'random')
			generator.settings.startAlpha = settings.startAlpha

	// Check if settings.endAlpha exists and checking if it is a number or a string, if it is a string it must be === to 'random
	if (settings.endAlpha || settings.endAlpha === 0)
		if (Util.isNumber(settings.endAlpha) || Util.isString(settings.endAlpha) && settings.endAlpha === 'random')
			generator.settings.endAlpha = settings.endAlpha

	// Check if settings.endSpeed exists
	if (settings.endSpeed || settings.endSpeed === 0)
		// If settings.endSpeed is a number
		if (Util.isNumber(settings.endSpeed))
			generator.settings.endSpeed = settings.endSpeed

		// If settings.endSpeed is a object
		else if (Util.isObject(settings.endSpeed))
			if (Util.isNumber(settings.endSpeed?.randomBetween[0]) && Util.isNumber(settings.endSpeed?.randomBetween[1]))
				generator.settings.endSpeed = settings.endSpeed

	// Check if settings.endSize exists
	if (settings.endSize || settings.endSize === 0)
		// If settings.endSize is a number
		if (Util.isNumber(settings.endSize))
			generator.settings.endSize = settings.endSize
			
		// If settings.endSize is a object
		else if (Util.isObject(settings.endSize))
			if (Util.isNumber(settings.endSize?.randomBetween[0]) && Util.isNumber(settings.endSize?.randomBetween[1]))
				generator.settings.endSize = settings.endSize

	// Check if settings.mapInfo exist and checking if it is a ojbect, also checking if the vars inside are of the right type
	if (settings.mapInfo && Util.isObject(settings.mapInfo))
		if (Util.isNumber(settings.mapInfo?.xPos) && Util.isNumber(settings.mapInfo?.yPos) && Util.isString(settings.mapInfo?.mapName))
			generator.settings.mapInfo = settings.mapInfo
			if (settings.mapInfo?.useEmitterPos)
				// Warning that you used set it to use the emitters's position but you also supplied valid positions. Supplied positions have higher priority and these are used.
				settings.mapInfo.useEmitterPos = false

		else if (settings.mapInfo?.useEmitterPos)
			generator.settings.mapInfo.useEmitterPos = true
		else
			// Warning that you supplied a object, but the vars were invalid or missing.

	// If the generator is to playOnCreation and there is no startDelay
	if (settings.playOnCreation && !settings.startDelay)
		// Assign var values
		generator.settings.playOnCreation = true
		generator.settings.startDelay = 0
		// Start it !
		generator.start()
	// If the generator is to playOnCreation and there IS a startDelay
	else if (settings.playOnCreation && settings.startDelay)
		// Assign var values
		generator.settings.playOnCreation = true
		generator.settings.startDelay = 0 // should be true (or a value), however as `playOnCreation` has more priority, this has been overrided
		// Start it !
		generator.start()
		// Display Warning
		// Play on creation was set to true, however `startDelay` also had a value, these options conflict with each other and as `playOnCreation` has more priority, it has been used

	// If the generator is NOT to playOnCreation and there IS a startDelay
	else if (!settings.playOnCreation && settings.startDelay)
		// Assign var values
		generator.settings.playOnCreation = false
		generator.settings.startDelay = settings.startDelay
		// Add it to the ticker so it can begin counting down the delay until it can start
		Event.addTicker(generator)
	else
		generator.settings.playOnCreation = true
		generator.start()

	return generator

ParticleGenerator
	// {'r': x, 'g': x, 'b': x }, {'r': x, 'g': x, 'b': x }
	// This is a array that holds all particles generated by the generator
	var gendParticles = []
	// This is a object that holds various settings for the particle generator
	var settings = {
		// active is whether this generator is active or not, it becomes active after `start` is called. and its no longer active when its collected or paused.
		'active': false,
		// paused is whether this generator is paused or not
		'paused': false,
		// pausable is whether this generator will be paused when the screen loses focus
		'pausable': false,
		// loop is whether the particle generator loops
		'loop': false,
		// playOnCreation is whether the particle generator starts immedietly when it is created
		'playOnCreation': true,
		// number of particles to spawn
		'number': 25,
		// duration of the particle generator
		'duration': 500,
		// radius can be a integer depicting the radius between particles
		'radius': 0, // rename this?
		// texture can be a diob to get the appearance of, or an valid iconName inside of particle_atlas
		'texture': 'particle',
		// orientation is the orientation in which the particles line up in, these are directional values, and `none` should be use for diobs to flow freely
		'orientation': 'south',
		// angleOverLifetime is the angle velocity in degrees in a update tick 10ms
		'angleOverLifetime': 0,
		// alphaOverLifetime is a beziercurve function depicting the alpha over the lifetime
		'alphaOverLifetime': null,
		// colorOverLifetime is an hex or an rgb with the color the particle should be at the end of its lifetime rgbString.match(/\d+/g) (formula)
		'colorOverLifetime': null,
		// sizeOverLifetime is a bezier curve defining the particiles size over its lifetime
		'sizeOverLifetime': null,
		// speedOverLifetime is a beziercurve function depicting the curve and the speed over the lifetime
		'speedOverLifetime': null,
		// startDelay is the delay in ms before the particle generator starts. If this is set and playOnCreation is true, playOnCreation is ignored.
		'startDelay': 0,
		// startColor can be a hex or rgb or a object containing two colors to pick a random color between 'startColor': { 'randomBetween': [hexOrRGB, hexOrRGB] }
		'startColor': '#ffffff',
		// startLifetime can be a integer or a object containing two numbers to pick a random number between 'startLifetime': { 'randomBetween': [num1, num2] }
		'startLifetime': 0,
		// startAngle can be a integer or a object containing two numbers to pick a random number between 'startAngle': { 'randomBetween': [num1, num2] }
		'startAngle': 0,
		// startSize can be a integer or a object containing two numbers to pick a random number between 'startSize': { 'randomBetween': [num1, num2] }
		'startSize': 0.3,
		// startSpeed can be a integer or a object containing two numbers to pick a random number between 'startSpeed': { 'randomBetween': [num1, num2] }
		'startSpeed': 0.5,
		// startAlpha can be a integer between 0-1 or 0 or 1 itself or a string 'random' for `Math.random()` to be used.
		'startAlpha': 0,
		// endSize MUST be used in tandem with `sizeOverLifetime` or else this value is ignored. This is the size the particle will be at the end of its lifetime can be a integer or a object containing two numbers to pick a random number between 'startSize': { 'randomBetween': [num1, num2] }
		'endSize': null,
		// endSpeed MUST be used in tandem with `speedOverLifetime` or else this value is ignored. This is the speed the particle will be at the end of its lifetime can be a integer or a object containing two numbers to pick a random number between 'startSpeed': { 'randomBetween': [num1, num2] }
		'endSpeed': null,
		// endAlpha MUST be used in tandem with `alphaOverLifetime` or else this value is ignored. This is the alpha the particle will be at the end of its lifetime can be a integer ar a string 'random' to depict `Math.random()` to be used.
		'endAlpha': null,
		// emitter is the diob that owns this particle generator. This var is preset when `diob.attachParticleGenerator` is called. `diob` is emitter
		'emitter': null,
		// mapInfo is an object with information on where to put the "particle generator"
		'mapInfo': { 'xPos': 1, 'yPos': 1, 'mapName': null, 'useEmitterPos': true },
		// interfaceInfo is an object with information on where to put the particle generator in the interface
		'interfaceInfo': { 'xPos': 1, 'yPos': 1, 'interface': '' },
		// plane is the plane that will be set for the attachParticleGenerator
		'plane': MAX_PLANE,
	}

	function setup()
		LIBRARY_activeGenerators.push(this)

	function packup()
		LIBRARY_activeGenerators.splice(LIBRARY_activeGenerators.indexOf(this), 1)

	onNew()
		this.setup()

	onDel()
		this.stop()
		
	function onDumped(array)
		this.setup()

	function onCollected(array)
		this.packup()
		
	function clean()
		this.settings = Type.getVariable(this.type, 'settings')
		aRecycle.collect(this.gendParticles, LIBRARY_particleArray)
		this.gendParticles = []

	function generateParticles()
		this.gendParticles = (this.settings.number === 1) ? [aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_particleArray, false, this.settings, this)] : aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_particleArray, false, this.settings, this)

	function setActive(elem)
		elem.info.active = true

	function removeParticle(particle)
		particle.info.active = false
		foreach (var p in this.gendParticles)
			if (p.info.active)
				return
		this.stop()

	function start()
		this.generateParticles()
		this.gendParticles.forEach(this.setActive)
		this.gendParticles.forEach(this.update.bind(this))
		// the generator is now active and all particles are active so this is now active
		this.settings.active = true
		Event.addTicker(this)

	function stop()
		this.pause()
		Event.removeTicker(this)
		aRecycle.collect(this, LIBRARY_particleGenArray)
		
	function pause()
		// the generator is paused and all particles have been paused so this is now inactive
		this.settings.active = false
		this.settings.paused = true

	function resume()
		// the generator is unpaused and all particles have been unpaused so this is now active
		this.settings.active = true
		this.settings.paused = false

	function setScaleOfParticle(particle, lifetimePercent)
		if (particle.info.sizeOverLifetime && (particle.info.eSize || particle.info.eSize === 0))
			var startSize = (particle.info.startSize?.randomBetween ? particle.info.sSize : particle.info.startSize)
			particle.scale.x = (startSize > particle.info.eSize ? startSize - particle.info.sizeOverLifetime(lifetimePercent) * (particle.info.eSize ? startSize - particle.info.eSize : startSize) : particle.info.sizeOverLifetime(lifetimePercent) * particle.info.eSize)
			particle.scale.y = particle.scale.x
			return true

	function setAlphaOfParticle(particle, lifetimePercent)
		if (particle.info.alphaOverLifetime && (particle.info.eAlpha || particle.info.eAlpha === 0))
			// if particle.info.startAlpha is `random`
			// startAlpha is to assume the startAlpha position, this is to take care of `random` startAlpha
			var startAlpha = (particle.info.startAlpha === 'random' ? particle.info.sAlpha : particle.info.startAlpha)
			particle.alpha = (startAlpha > particle.info.eAlpha ? startAlpha - particle.info.alphaOverLifetime(lifetimePercent) * (particle.info.eAlpha ? startAlpha - particle.info.eAlpha : startAlpha) : particle.info.alphaOverLifetime(lifetimePercent) * particle.info.eAlpha)
			return true

	function setSpeedOfParticle(particle, lifetimePercent)
		if (particle.info.speedOverLifetime && (particle.info.eSpeed || particle.info.eSpeed === 0))
			var startSpeed = (particle.info.startSpeed?.randomBetween ? particle.info.sSpeed : particle.info.startSpeed)
			particle.info.speed = (startSpeed > particle.info.eSpeed ? startSpeed - particle.info.speedOverLifetime(lifetimePercent) * (particle.info.eSpeed ? startSpeed - particle.info.eSpeed : startSpeed) : particle.info.speedOverLifetime(lifetimePercent) * particle.info.eSpeed)
			return true

	function update(particle)
		if (particle)
			if (particle?.info?.active)
				particle.info.lifetime += PARTICLE_GENERATOR_TICK_RATE
				// var lifetimePercent = (Date.now() - particle.info.startStamp) / particle.info.duration
				var lifetimePercent = particle.info.lifetime / particle.info.duration
				this.setScaleOfParticle(particle, lifetimePercent)
				this.setAlphaOfParticle(particle, lifetimePercent)
				this.setSpeedOfParticle(particle, lifetimePercent)
				
				particle.angle += Util.toRadians(particle.info.angleOverLifetime)
				// particle.text = particle.alpha

				if (Util.toDegrees(particle.angle) >= 360)
					particle.angle = 0
	// Update Trajectory with speed
				particle.setTrajectory()
	// Update Position after speed change
				if (particle.info.interfaceInfo.interface)
					particle.setPos(particle.xPos + particle.info.trajectory.x, particle.yPos + particle.info.trajectory.y)
				else
					particle.setPos(particle.xPos + particle.info.trajectory.x, particle.yPos + particle.info.trajectory.y, particle.mapName)
	// Reset if looping, collect if not, Collecting removes it from the array
				if (particle.info.lifetime >= particle.info.duration)
					var percent2
					if (this.settings.loop)
	// If the particle generator is set to loop then check all of the particles settings to see if anything needs to be randomized again
	// Plane			
						if (particle.info.plane)
							if (Util.isObject(particle.info.plane))
								particle.plane = LIBRARY_rand(particle.info.plane.randomBetween[0], particle.info.plane.randomBetween[1])
							else
								particle.plane = particle.info.plane
	// StartColor
						if (Util.isObject(particle.info.startColor))
							particle.color = { 'tint': aUtils.grabColor(JS.getRandomColorBetween(particle.info.startColor.randomBetween[0], particle.info.startColor.randomBetween[1])).decimal }
						else if (particle.info.startColor.includes('rgb'))
							var rgbArray = particle.info.startColor.match(Util.regExp('\\d+', 'g'))
							var decimal = aUtils.grabColor(rgbArray[0], rgbArray[1], rgbArray[2]).decimal
							particle.color = { 'tint': decimal }
						else
							particle.color = { 'tint': aUtils.grabColor(particle.info.startColor).decimal }
	// StartLifetime
						if (Util.isObject(particle.info.startLifetime))
							particle.info.lifetime = LIBRARY_rand(particle.info.startLifetime.randomBetween[0], particle.info.startLifetime.randomBetween[1])
							percent2 = particle.info.lifetime / particle.info.duration
						else
							particle.info.lifetime = particle.info.startLifetime
	// EndAlpha
						if (Util.isString(particle.info.endAlpha))
							particle.info.eAlpha = LIBRARY_rand(0.1, 0.4)
						else
							particle.info.eAlpha = particle.info.endAlpha
	// EndSpeed
						if (Util.isObject(particle.info.endSpeed))
							particle.info.eSpeed = LIBRARY_rand(particle.info.endSpeed.randomBetween[0], particle.info.endSpeed.randomBetween[1])
						else
							particle.info.eSpeed = particle.info.endSpeed
	// EndSize
						if (Util.isObject(particle.info.endSize))
							particle.info.eSize = LIBRARY_rand(particle.info.endSize.randomBetween[0], particle.info.endSize.randomBetween[1])
						else
							particle.info.eSize = particle.info.endSize
	// StartAlpha
						if (Util.isString(particle.info.startAlpha))
							var alphaRand = LIBRARY_rand(0.1, 0.4)
	// sAlpha
							particle.info.sAlpha = alphaRand
							if (percent2) // means the lifetime is not natural
								this.setAlphaOfParticle(particle, percent2)
							else
								particle.alpha = alphaRand
						else
							if (percent2) // means the lifetime is not natural
								this.setAlphaOfParticle(particle, percent2)
							else
								particle.alpha = particle.info.startAlpha
	// StartSize
						if (Util.isObject(particle.info.startSize))
							var sizeRand = LIBRARY_rand(particle.info.startSize.randomBetween[0], particle.info.startSize.randomBetween[1])
	// sSize
							particle.info.sSize = sizeRand
							if (percent2) // means the lifetime is not natural
								this.setScaleOfParticle(particle, percent2)
							else
								particle.scale = { 'x': sizeRand, 'y': sizeRand }
						else
							if (percent2) // means the lifetime is not natural
								this.setScaleOfParticle(particle, percent2)
							else
								particle.scale = particle.info.startSize
	// StartAngle
						if (Util.isObject(particle.info.startAngle))
							particle.angle = Util.toRadians(LIBRARY_rand(particle.info.startAngle.randomBetween[0], particle.info.startAngle.randomBetween[1]))
						else
							particle.angle = Util.toRadians(particle.info.startAngle)
	//	StartSpeed
						if (Util.isObject(particle.info.startSpeed))
							var speedRand = LIBRARY_rand(particle.info.startSpeed.randomBetween[0], particle.info.startSpeed.randomBetween[1])
	// sSpeed
							particle.info.sSpeed = speedRand
							if (percent2) // means the lifetime is not natural
								this.setSpeedOfParticle(particle, percent2)
							else
								particle.info.speed = speedRand
						else
							if (percent2) // means the lifetime is not natural
								this.setSpeedOfParticle(particle, percent2)
							else
								particle.info.speed = particle.info.startSpeed
	// ColorOverLifetime
						if (particle.info.colorOverLifetime)
							if (particle.color)
								var r = Math.floor(particle.color.tint / (256*256))
								var g = Math.floor(particle.color.tint / 256) % 256
								var b = particle.color.tint % 256
								var startColor = aUtils.grabColor(r, g, b).hex
								aUtils.transitionColor(particle, startColor, particle.info.colorOverLifetime, particle.info.duration - particle.info.lifetime)
							else
								aUtils.transitionColor(particle, '#ffffff', particle.info.colorOverLifetime, particle.info.duration - particle.info.lifetime)
	// StartStamp
						// particle.info.startStamp = Date.now() - particle.info.lifetime
	// Texture
						if (particle.info.texture)
							if (Util.isArray(particle.info.texture))
								particle.iconName = Util.pick(particle.info.texture)
	// Update TempAngle
						if (particle.info.tempAngle)
							particle.info.tempAngle.x = Math.random() * (Math.prob(50) ? 1 : - 1)
							particle.info.tempAngle.y = Math.random() * (Math.prob(50) ? 1 : - 1)
	// SetTrajectory after loop
						particle.setTrajectory()
	// SetPosAfterLoop	
						if (particle.info.owner.settings.emitter)
							if (particle.info.mapInfo?.useEmitterPos)
								if (particle.info.owner.settings.emitter?.mapName)
									var randomRadiusX = Math.rand(particle.info.owner.settings.emitter.xPos, particle.info.owner.settings.emitter.xPos + particle.info.radius)
									var randomRadiusY = Math.rand(particle.info.owner.settings.emitter.yPos, particle.info.owner.settings.emitter.yPos + particle.info.radius)
									particle.setPos(randomRadiusX + particle.info.trajectory.x, randomRadiusY + particle.info.trajectory.y, particle.mapName)
						else
							if (particle.info.interfaceInfo.interface)
								var randomRadiusX = Math.rand(particle.info.interfaceInfo.xPos, particle.info.interfaceInfo.xPos + particle.info.radius)
								var randomRadiusY = Math.rand(particle.info.interfaceInfo.yPos, particle.info.interfaceInfo.yPos + particle.info.radius)
								particle.setPos(randomRadiusX + particle.info.trajectory.x, randomRadiusY + particle.info.trajectory.y)
							else				
								var randomRadiusX = Math.rand(particle.info.mapInfo.xPos, particle.info.mapInfo.xPos + particle.info.radius)
								var randomRadiusY = Math.rand(particle.info.mapInfo.yPos, particle.info.mapInfo.yPos + particle.info.radius)
								particle.setPos(randomRadiusX + particle.info.trajectory.x, randomRadiusY + particle.info.trajectory.y, particle.mapName)
					else
						this.removeParticle(particle)

	onTick(t)
		if (!this.settings.paused)
			if (this.settings.startDelay)
				this.settings.startDelay = Math.clamp(this.settings.startDelay - PARTICLE_GENERATOR_TICK_RATE, 0, Infinity)
				if (!this.settings.startDelay)
					this.start()
			else
				if (this.settings.active)
					if (this.gendParticles.length)
						this.gendParticles.forEach(this.update.bind(this))
				else
					if (!this.settings.paused)
						Event.removeTicker(this)
						aRecycle.collect(this, LIBRARY_particleGenArray)

GeneratedParticle : inherit [Particle]
	atlasName = 'particle_atlas'
	// plane = MAX_PLANE
	layer = 1
	scale = { 'x': 0.3, 'y': 0.3 }
	mouseOpacity = 0
	touchOpacity = 0
	preventScreenRelayer = true
	// preventInterpolation = true
	textStyle = { 'fill': '#fff' }
	var info = {
		'duration': 0,
		'radius': 0,
		'lifetime': 0,
		'speed': 0.5,
		'orientation': 'south',
		'tempAngle': null, // This is not passed in but rather given as a means to store a `Math.random()` so that particle movement isn't finicky
		// 'startStamp': 0,
		'texture': null,
		'plane': 0,
		'mapInfo': { 'x': 1, 'y': 1, 'mapName': null, 'useEmitterPos': true },
		'interfaceInfo': { 'x': 1, 'y': 1, 'interface': '' },
		'startColor': null,
		'startAlpha': null,
		'startLifetime': null,
		'startAngle': null,
		'startSize': null,
		'startSpeed': null,
		'colorOverLifetime': null,
		'alphaOverLifetime': null,
		'angleOverLifetime': null,
		'sizeOverLifetime': null,
		'speedOverLifetime': null,
		'trajectory': { 'x': 0, 'y': 0 },
		'eSpeed': null,
		'eSize': null,
		'eAlpha': null,
		'endSize': null,
		'endSpeed': null,
		'endAlpha': null,
		// sAlpha is the `startAlpha` for when `random` is used
		'sAlpha': null,
		// sSpeed is the `startSpeed` for when `randomBetween` is used
		'sSpeed': null,
		// sSize is the `startSize` for when `randomBetween` is used
		'sSize': null,
		'owner': null,
		'active': false
	}

	// When this particle is shown, make it active.
	onScreenShow(client)
		if (!this.info.active)
			this.info.active = true

	// When this particle is hidden, make it inactive.
	onScreenHide(client)
		if (this.info.active)
			this.info.active = false

	onNew(info, owner, bypass)
		// you are just precreating some of these types, so no need to run the code just yet
		if (!info && !owner && !bypass)
			return
		if (bypass) // this is so a interface particle doesn not gets its `onNew` called again since we use `Client.addInterfaceElement`
			return
		this.setup(info, owner)

	function onDumped(array, info, owner)
		this.setup(info, owner)

	function clean()
		this.iconName = ''
		this.color = ''
		this.xPos = 0
		this.yPos = 0
		this.mapName = ''
		if (this.info.interfaceInfo.interface)
			Client.removeInterfaceElement(this.info.interfaceInfo.interface, this.id)
		this.info = {
			'duration': 0,
			'radius': 0,
			'lifetime': 0,
			'speed': 0.5,
			'orientation': 'south',
			'tempAngle': null, // This is not passed in but rather given as a means to store a `Math.random()` so that particle movement isn't finicky
			// 'startStamp': 0,
			'texture': null,
			'plane': 0,
			'mapInfo': { 'x': 1, 'y': 1, 'mapName': null, 'useEmitterPos': true },
			'interfaceInfo': { 'x': 1, 'y': 1, 'interface': '' },
			'startColor': null,
			'startAlpha': null,
			'startLifetime': null,
			'startAngle': null,
			'startSize': null,
			'startSpeed': null,
			'colorOverLifetime': null,
			'alphaOverLifetime': null,
			'angleOverLifetime': null,
			'sizeOverLifetime': null,
			'speedOverLifetime': null,
			'trajectory': { 'x': 0, 'y': 0 },
			'eSpeed': null,
			'eSize': null,
			'eAlpha': null,
			'endSize': null,
			'endSpeed': null,
			'endAlpha': null,
			// sAlpha is the `startAlpha` for when `random` is used
			'sAlpha': null,
			// sSpeed is the `startSpeed` for when `randomBetween` is used
			'sSpeed': null,
			// sSize is the `startSize` for when `randomBetween` is used
			'sSize': null,
			'owner': null,
			'active': false
	}

	function setup(info, owner)
		// All data coming in has already been prechecked, we just need to grab and assign a few things
		var lifetimePercent
// Duration
		this.info.duration = info.duration
// Radius
		this.info.radius = info.radius
// Orientation
		this.info.orientation = info.orientation
// Owner
		this.info.owner = owner
// Active
		this.info.active = true
// Texture
		if (info.texture?.type)
			this.setAppearance(info.texture)
		else if (Util.isArray(info.texture))
			this.iconName = Util.pick(info.texture)
		else
			this.iconName = info.texture
		this.info.texture = info.texture
// MapInfo
		this.info.mapInfo = info.mapInfo
// InterfaceInfo
		this.info.interfaceInfo = info.interfaceInfo
// Plane
		if (info.plane || info.plane === 0)
			if (Util.isObject(info.plane))
				this.plane = LIBRARY_rand(info.plane.randomBetween[0], info.plane.randomBetween[1])
			else
				this.plane = info.plane
			this.info.plane = info.plane
// Lifetime
		if (Util.isObject(info.startLifetime))
			this.info.lifetime = LIBRARY_rand(info.startLifetime.randomBetween[0], info.startLifetime.randomBetween[1])
// Percent
			lifetimePercent = this.info.lifetime / this.info.duration
		else
			this.info.lifetime = info.startLifetime
// StartLifetime
		this.info.startLifetime = info.startLifetime
// this.color
		if (Util.isObject(info.startColor))
			this.color = { 'tint': aUtils.grabColor(JS.getRandomColorBetween(info.startColor.randomBetween[0], info.startColor.randomBetween[1])).decimal }
		else if (info.startColor.includes('rgb'))
			var rgbArray = info.startColor.match(Util.regExp('\\d+', 'g'))
			var decimal = aUtils.grabColor(rgbArray[0], rgbArray[1], rgbArray[2]).decimal
			this.color = { 'tint': decimal }
		else
			this.color = { 'tint': aUtils.grabColor(info.startColor).decimal }

// StartColor
		this.info.startColor = info.startColor
// ColorOverTime
		this.info.colorOverLifetime = info.colorOverLifetime
		if (this.info.colorOverLifetime)
			if (this.color)
				var startColor
				if (this.color?.tint)
					var r = Math.floor(this.color.tint / (256*256))
					var g = Math.floor(this.color.tint / 256) % 256
					var b = this.color.tint % 256
					startColor = aUtils.grabColor(r, g, b).hex
				else
					startColor = '#FFFFFF'
				aUtils.transitionColor(this, startColor, info.colorOverLifetime, info.duration - this.info.lifetime)
			else
				aUtils.transitionColor(this, '#FFFFFF', info.colorOverLifetime, info.duration - this.info.lifetime)

// AlphaOverLifetime
		this.info.alphaOverLifetime = info.alphaOverLifetime
// AngleOverLifetime
		this.info.angleOverLifetime = info.angleOverLifetime
// SizeOverTime
		this.info.sizeOverLifetime = info.sizeOverLifetime
// SpeedOverTime
		this.info.speedOverLifetime = info.speedOverLifetime
// StartAlpha		
		this.info.startAlpha = info.startAlpha
// StartSize
		this.info.startSize = info.startSize
// StartSpeed
		this.info.startSpeed = info.startSpeed
// StartAngle
		this.info.startAngle = info.startAngle
// eAlpha
		if (Util.isString(info.endAlpha))
			this.info.eAlpha = LIBRARY_rand(0.1, 0.4)
		else
			this.info.eAlpha = info.endAlpha
// EndAlpha
		this.info.endAlpha = info.endAlpha

// eSize
		if (Util.isObject(info.endSize))
			this.info.eSize = LIBRARY_rand(info.endSize.randomBetween[0], info.endSize.randomBetween[1])
		else
			this.info.eSize = info.endSize
// EndSize
		this.info.endSize = info.endSize
// eSpeed
		if (Util.isObject(info.endSpeed))
			this.info.eSpeed = LIBRARY_rand(info.endSpeed.randomBetween[0], info.endSpeed.randomBetween[1])
		else
			this.info.eSpeed = info.endSpeed
// EndSpeed
		this.info.endSpeed = info.endSpeed

// Alpha
		if (Util.isString(info.startAlpha))
			var alphaRand = LIBRARY_rand(0.1, 0.4)
// sAlpha
			this.info.sAlpha = alphaRand
			if (lifetimePercent && info.endAlpha)
				owner.setAlphaOfParticle(this, lifetimePercent)
			else
				this.alpha = alphaRand
		else
			if (lifetimePercent && info.endAlpha)
				owner.setAlphaOfParticle(this, lifetimePercent)
			else
				this.alpha = info.startAlpha
// Size / Scale
		if (Util.isObject(info.startSize))
			var sizeRand = LIBRARY_rand(info.startSize.randomBetween[0], info.startSize.randomBetween[1])
// sSize
			this.info.sSize = sizeRand
			if (lifetimePercent && this.endSize)
				owner.setScaleOfParticle(this, lifetimePercent)
			else
				this.scale = { 'x': sizeRand, 'y': sizeRand }
		else
			if (lifetimePercent && this.endSize)
				owner.setScaleOfParticle(this, lifetimePercent)
			else
				this.scale = { 'x': info.startSize, 'y': info.startSize }
// Angle
		if (Util.isObject(info.startAngle))
			this.angle = Util.toRadians(LIBRARY_rand(info.startAngle.randomBetween[0], info.startAngle.randomBetween[1]))
		else
			this.angle = Util.toRadians(info.startAngle)
// Speed
		if (Util.isObject(info.startSpeed))
			var speedRand = LIBRARY_rand(info.startSpeed.randomBetween[0], info.startSpeed.randomBetween[1])
// sSpeed
			this.info.sSpeed = speedRand
			if (lifetimePercent && info.endSpeed)
				owner.setSpeedOfParticle(this, lifetimePercent)
			else
				this.info.speed = speedRand
		else
			if (lifetimePercent && info.endSpeed)
				owner.setSpeedOfParticle(this, lifetimePercent)
			else
				this.info.speed = info.startSpeed
// StartStamp
		// this.info.startStamp = Date.now() - this.info.lifetime
// SetTrajectory
		this.setTrajectory()
// SetPos
		if (this.info.interfaceInfo.interface)
			var randomRadiusX = Math.rand(this.info.interfaceInfo.xPos, this.info.interfaceInfo.xPos + this.info.radius)
			var randomRadiusY = Math.rand(this.info.interfaceInfo.yPos, this.info.interfaceInfo.yPos + this.info.radius)
			Client.addInterfaceElement(this, this.info.interfaceInfo.interface, this.id, randomRadiusX + this.info.trajectory.x, randomRadiusY + this.info.trajectory.y, [null, null, true])
		else
			// Only attemp to set the position if you have a valid `mapInfo` object
			if (this.info.mapInfo)
				// The owner of this (particle) is the particle generator, however we want the emitter of the particle generator itself so only use `useEmitterPos` in the condition that the particle gen has a emitter
				if (owner.settings.emitter)
					if (this.info.mapInfo.useEmitterPos)
						// Only place it if the emitter has a valid mapName
						if (owner.settings.emitter.mapName)
							var randomRadiusX = Math.rand(owner.settings.emitter.xPos, owner.settings.emitter.xPos + this.info.radius)
							var randomRadiusY = Math.rand(owner.settings.emitter.yPos, owner.settings.emitter.yPos + this.info.radius)
							this.setPos(randomRadiusX + this.info.trajectory.x, randomRadiusY + this.info.trajectory.y, owner.settings.emitter.mapName)
				// There was no emitter of the particle gen so we use the `mapInfo` object that was given to us
				else
					var randomRadiusX = Math.rand(this.info.mapInfo.xPos, this.info.mapInfo.xPos + this.info.radius)
					var randomRadiusY = Math.rand(this.info.mapInfo.yPos, this.info.mapInfo.yPos + this.info.radius)
					this.setPos(randomRadiusX + this.info.trajectory.x, randomRadiusY + this.info.trajectory.y, this.info.mapInfo.mapName)

	function setTrajectory()
		if (this.info.orientation)
			var angle = LIBRARY_getAngleFromDir(this.info.orientation)
			switch (this.info.orientation)
				case 'north':
				case 'south':
				case 'east':
				case 'west':
				case 'northwest':
				case 'southwest':
				case 'northeast':
				case 'southeast':
					this.info.trajectory = { 'x': this.info.speed * Math.cos(angle), 'y': this.info.speed * -Math.sin(angle) }
					break

				case 'none':
					// if continiously called then save the `Math.random` into a temp
					if (!this.info.tempAngle)
						this.info.tempAngle = { 'x': Math.random() * (Math.prob(50) ? 1 : - 1), 'y': Math.random() * (Math.prob(50) ? 1 : - 1) }
					this.info.trajectory = { 'x': this.info.speed * this.info.tempAngle.x, 'y': this.info.speed * this.info.tempAngle.y }

function LIBRARY_getAngleFromDir(dir)
	switch (dir)
		case 'north':
			return (Math.PI / 2)
		case 'south':
			return (Math.PI * 3) / 2
		case 'east':
			return (Math.PI * 2)
		case 'west':
			return Math.PI
		case 'northwest':
			return (Math.PI * 3) / 4
		case 'northeast':
			return Math.PI / 4
		case 'southwest':
			return (Math.PI * 5) / 4
		case 'southeast':
			return (Math.PI * 7) / 4

function BezierEasing(x1, y1, x2, y2)
	return JS.BezierEasing(x1, y1, x2, y2)

function LIBRARY_rand(num1, num2)
	var result = Util.toNumber((Math.random() * (num1 - num2) + num2).toFixed(1))
	return (result >= 1 ? Math.floor(result) : result)

#BEGIN JAVASCRIPT

function getRandomColorBetween(color1, color2) {
	var generator = new RandomColor(color1, color2);
	var color = generator.getColor();
	return color;
}

function getValues (color) {
	var values = false;
	var _regs = {
		"hex3": /^#([a-f\d])([a-f\d])([a-f\d])$/i,
		"hex6": /^#([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i,
		"rgb": /^rgb\s*\(\s*([\d\.]+%?)\s*\,\s*([\d\.]+%?)\s*\,\s*([\d\.]+%?)\s*\)$/
	};
	for (var prop in _regs) {
		if (_regs[prop].test(color)) {
			values = {};
			values.r = color.replace(_regs[prop], "$1");
			values.g = color.replace(_regs[prop], "$2");
			values.b = color.replace(_regs[prop], "$3");
			if (prop === "rgb") {
				values.r = Number(values.r);
				values.g = Number(values.g);
				values.b = Number(values.b);
			} else {
				values.r = parseInt(values.r, 16);
				values.g = parseInt(values.g, 16);
				values.b = parseInt(values.b, 16);
			}
			break;
		}
	}
	return values;
}

function str_pad(str, pad_length, pad_string, pad_type) {
	var len = pad_length - str.length;
	if (len < 0) { return str };
	var pad = new Array(len + 1).join(pad_string);
	if (pad_type === "STR_PAD_LEFT") { return pad + str };
	return str + pad;
}

function getRandom(c1, c2, pcent) {
	var color = c1 + Math.floor((c2 - c1) * pcent);
	if (color < 0) color = 0;
	return str_pad(color.toString(16), 2, "0", "STR_PAD_LEFT");
}

function RandomColor(color1, color2) {
	var _obj1 = getValues(color1);
	var _obj2 = getValues(color2);

	this.getColor = function () {
		if (_obj1 && _obj2) {
			var random = Math.random();
			var r = getRandom(_obj1.r, _obj2.r, random);
			var g = getRandom(_obj1.g, _obj2.g, random);
			var b = getRandom(_obj1.b, _obj2.b, random);

			return "#" + r + g + b;
		}
		return false;
	};
}

/**
 * BezierEasing - use bezier curve for transition easing function
 * by Gaëtan Renaudeau 2014 – MIT License
 *
 * Credits: is based on Firefox's nsSMILKeySpline.cpp
 * Usage:
 * var spline = BezierEasing(0.25, 0.1, 0.25, 1.0)
 * spline(x) => returns the easing value | x must be in [0, 1] range
 *
 */
(function (definition) {
  if (typeof exports === "object") {
    module.exports = definition();
  } else if (typeof define === 'function' && define.amd) {
    define([], definition);
  } else {
    window.BezierEasing = definition();
  }
}(function () {
  var global = this;

  // These values are established by empiricism with tests (tradeoff: performance VS precision)
  var NEWTON_ITERATIONS = 4;
  var NEWTON_MIN_SLOPE = 0.001;
  var SUBDIVISION_PRECISION = 0.0000001;
  var SUBDIVISION_MAX_ITERATIONS = 10;

  var kSplineTableSize = 11;
  var kSampleStepSize = 1.0 / (kSplineTableSize - 1.0);

  var float32ArraySupported = 'Float32Array' in global;

  function A (aA1, aA2) { return 1.0 - 3.0 * aA2 + 3.0 * aA1; }
  function B (aA1, aA2) { return 3.0 * aA2 - 6.0 * aA1; }
  function C (aA1)      { return 3.0 * aA1; }

  // Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
  function calcBezier (aT, aA1, aA2) {
    return ((A(aA1, aA2)*aT + B(aA1, aA2))*aT + C(aA1))*aT;
  }

  // Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
  function getSlope (aT, aA1, aA2) {
    return 3.0 * A(aA1, aA2)*aT*aT + 2.0 * B(aA1, aA2) * aT + C(aA1);
  }

  function binarySubdivide (aX, aA, aB) {
    if (!mX1 || !mX2) {
	  var mX1 = 0;
	  var mX2 = 0;
    }
    var currentX, currentT, i = 0;
    do {
      currentT = aA + (aB - aA) / 2.0;
      currentX = calcBezier(currentT, mX1, mX2) - aX;
      if (currentX > 0.0) {
        aB = currentT;
      } else {
        aA = currentT;
      }
    } while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);
    return currentT;
  }

  function BezierEasing (mX1, mY1, mX2, mY2) {
    // Validate arguments
    if (arguments.length !== 4) {
      throw new Error("BezierEasing requires 4 arguments.");
    }
    for (var i=0; i<4; ++i) {
      if (typeof arguments[i] !== "number" || isNaN(arguments[i]) || !isFinite(arguments[i])) {
        throw new Error("BezierEasing arguments should be integers.");
      }
    }
    if (mX1 < 0 || mX1 > 1 || mX2 < 0 || mX2 > 1) {
      throw new Error("BezierEasing x values must be in [0, 1] range.");
    }

    var mSampleValues = float32ArraySupported ? new Float32Array(kSplineTableSize) : new Array(kSplineTableSize);

    function newtonRaphsonIterate (aX, aGuessT) {
      for (var i = 0; i < NEWTON_ITERATIONS; ++i) {
        var currentSlope = getSlope(aGuessT, mX1, mX2);
        if (currentSlope === 0.0) return aGuessT;
        var currentX = calcBezier(aGuessT, mX1, mX2) - aX;
        aGuessT -= currentX / currentSlope;
      }
      return aGuessT;
    }

    function calcSampleValues () {
      for (var i = 0; i < kSplineTableSize; ++i) {
        mSampleValues[i] = calcBezier(i * kSampleStepSize, mX1, mX2);
      }
    }

    function getTForX (aX) {
      var intervalStart = 0.0;
      var currentSample = 1;
      var lastSample = kSplineTableSize - 1;

      for (; currentSample != lastSample && mSampleValues[currentSample] <= aX; ++currentSample) {
        intervalStart += kSampleStepSize;
      }
      --currentSample;

      // Interpolate to provide an initial guess for t
      var dist = (aX - mSampleValues[currentSample]) / (mSampleValues[currentSample+1] - mSampleValues[currentSample]);
      var guessForT = intervalStart + dist * kSampleStepSize;

      var initialSlope = getSlope(guessForT, mX1, mX2);
      if (initialSlope >= NEWTON_MIN_SLOPE) {
        return newtonRaphsonIterate(aX, guessForT);
      } else if (initialSlope === 0.0) {
        return guessForT;
      } else {
        return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize);
      }
    }

    var _precomputed = false;
    function precompute() {
      _precomputed = true;
      if (mX1 != mY1 || mX2 != mY2)
        calcSampleValues();
    }

    var f = function (aX) {
      if (!_precomputed) precompute();
      if (mX1 === mY1 && mX2 === mY2) return aX; // linear
      // Because JavaScript number are imprecise, we should guarantee the extremes are right.
      if (aX === 0) return 0;
      if (aX === 1) return 1;
      return calcBezier(getTForX(aX), mY1, mY2);
    };

    f.getControlPoints = function() { return [{ x: mX1, y: mY1 }, { x: mX2, y: mY2 }]; };

    var args = [mX1, mY1, mX2, mY2];
    var str = "BezierEasing("+args+")";
    f.toString = function () { return str; };

    var css = "cubic-bezier("+args+")";
    f.toCSS = function () { return css; };

    return f;
  }

  // CSS mapping
  BezierEasing.css = {
    "ease":        BezierEasing(0.25, 0.1, 0.25, 1.0),
    "linear":      BezierEasing(0.00, 0.0, 1.00, 1.0),
    "ease-in":     BezierEasing(0.42, 0.0, 1.00, 1.0),
    "ease-out":    BezierEasing(0.00, 0.0, 0.58, 1.0),
    "ease-in-out": BezierEasing(0.42, 0.0, 0.58, 1.0)
  };

  return BezierEasing;

}));

#END JAVASCRIPT
#END CLIENTCODE
