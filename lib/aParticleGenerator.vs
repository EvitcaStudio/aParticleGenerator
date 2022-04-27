#DEFINE MAX_PLANE 999999

GeneratedParticle : inherit [Particle]

#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

let LIBRARY_particleGenArray = []
let LIBRARY_mapParticleArray = []
let LIBRARY_screenParticleArray = []
let LIBRARY_activeGenerators = []

const PARTICLE_GENERATOR_TICK_RATE = 10
const MAX_ELAPSED_MS = 100
const OUTLINE_PLANE = 999666
const BLOOM_PLANE = 999777
const BLOOM_OUTLINE_PLANE = 999888

Client
	let _pg_screenPos = {}
	let _pg_gameSize = {}

	onNew()
		let gameSize = World.getGameSize()
		this._pg_gameSize.width = gameSize.width
		this._pg_gameSize.height = gameSize.height
		this.timeScale = (this.timeScale || this.timeScale === 0 ? this.timeScale : 1)

	onWindowFocus()
		foreach (let gen in LIBRARY_activeGenerators)
			if (gen.settings.pausable)
				gen.resume()

	onWindowBlur()
		foreach (let gen in LIBRARY_activeGenerators)
			if (gen.settings.pausable)
				gen.pause()

Diob
	function getGeneratorById(pID)
		// If you don't already have a particle generator assigned to this diob assign one
		if (!this.particleGenerators)
			this.particleGenerators = {}

		if (!pID)
			JS.console.error('aParticleGenerator[getGeneratorById]: No %cpID', 'font-weight: bold', 'parameter passed.')
			return

		if (this.particleGenerators[pID])
			return this.particleGenerators[pID]
		JS.console.error('aParticleGenerator[getGeneratorById pID: ' + pID + ']: No %cParticle Generator', 'font-weight: bold', 'attached to this diob exists with that ID.')

	function attachParticleGenerator(pSettings, pID)
		// If you don't already have a particle generator assigned to this diob assign one
		if (!this.particleGenerators)
			this.particleGenerators = {}
		
		if (this.particleGenerators[pID])
			JS.console.error('aParticleGenerator[attachParticleGenerator pID: ' + pID + ']: A %cParticle Generator', 'font-weight: bold', 'with that ID is already attached to this diob.')
			return

		if (!pID)
			JS.console.error('aParticleGenerator[attachParticleGenerator]: There was no %cpID', 'font-weight: bold', 'parameter passed. pID is CRUCIAL to using particle generators. It needs an ID so it be referenced for deletion later.')
			return

		// add the ID to the pSettings object so it can be stored
		pSettings.id = pID
		// Create a particle generator
		this.particleGenerators[pID] = createParticleGenerator(pSettings, this)

	function detachParticleGenerator(pID)
		if (!this.particleGenerators)
			JS.console.error('aParticleGenerator[detachParticleGenerator pID: ' + pID + ']: No %cParticle Generator', 'font-weight: bold', 'attached to this diob.')
			return

		if (this.particleGenerators[pID])
			this.particleGenerators[pID].destroy(true)
			return
		JS.console.error('aParticleGenerator[detachParticleGenerator pID: ' + pID + ']: No %cParticle Generator', 'font-weight: bold', 'attached to this diob exists with that ID.')

function createParticleGenerator(pSettings, pEmitter)
	let missingaUtils = aUtils ? false : true
	let missingaRecycle = aRecycle ? false : true
	let missingaLight = aLight ? false : true
	let missingPIXIJS = JS.PIXI.filters.OutlineFilter ? false : true
	if (missingaUtils || missingaRecycle)
		if (missingaUtils)
			JS.console.error('aParticleGenerator[createParticleGenerator]: The %caUtils', 'font-weight: bold', 'library is missing. Please obtain it from https://github.com/aHouseStudio/aUtils')
		if (missingaRecycle)
			JS.console.error('aParticleGenerator[createParticleGenerator]: The %caRecycle', 'font-weight: bold', 'library is missing. Please obtain it from https://github.com/aHouseStudio/aRecycle')
		if (missingaLight || missingPIXIJS)
			if (missingaLight)
				JS.console.warn('aParticleGenerator[createParticleGenerator]: The %caLight', 'font-weight: bold', 'library is missing. This library is ONLY needed if you want to use the light property. Please obtain it from https://github.com/aHouseStudio/aLight')
			if (missingPIXIJS)
				JS.console.warn('aParticleGenerator[createParticleGenerator]: The %cpixiJS filters', 'font-weight: bold', 'library is missing. This library is ONLY needed if you want to use the outlineFilter or bloomFilter property. Please obtain it from https://www.npmjs.com/package/pixi-filters')
		return

	let generator = aRecycle.isInCollection('ParticleGenerator', 1, LIBRARY_particleGenArray, true)
	
	if (!pSettings)
		return generator

	generator.settings.sizeOverLifetime = BezierEasing(0, 0, 0.58, 1)
	generator.settings.speedOverLifetime = BezierEasing(0, 0, 0.58, 1)
	generator.settings.alphaOverLifetime = BezierEasing(0, 0, 0.58, 1)

	if (pSettings.sizeOverLifetime)
		if (Util.getVariableType(pSettings.sizeOverLifetime) === 'function')
			generator.settings.sizeOverLifetime = pSettings.sizeOverLifetime
		else
			// warning that this is a invalid variable type for this variable

	if (pSettings.speedOverLifetime)
		if (Util.getVariableType(pSettings.speedOverLifetime) === 'function')
			generator.settings.speedOverLifetime = pSettings.speedOverLifetime
		else
			// warning that this is a invalid variable type for this variable

	if (pSettings.alphaOverLifetime)
		if (Util.getVariableType(pSettings.alphaOverLifetime) === 'function')
			generator.settings.alphaOverLifetime = pSettings.alphaOverLifetime
		else
			// warning that this is a invalid variable type for this variable

	// Valid texture(s) for the particle to use
	let validTextures = Icon.getIconNames('particle_atlas')
	// Valid Composite(s) for the particle to use
	let validComposites = ['normal', 'add', 'source-over', 'source-atop', 'source-in', 'source-out', 'destination-over', 
		'destination-atop', 'destination-in', 'destination-out', 
		'lighter', 'copy', 'xor', 'multiply', 'screen', 'overlay', 'darken', 'lighten', 
		'color-dodge', 'color-burn', 'hard-light', 'soft-light', 'difference', 
		'exclusion', 'hue', 'saturation', 'color', 'luminosity'
	]

	// Emitter
	if (pEmitter)
		generator.settings.emitter = pEmitter
		generator.owner = pEmitter
	
	// id of this generator
	if (pSettings.id)
		generator.settings.id = pSettings.id

	if (pSettings.debugging) 
		generator.debugging = true

	// Check if pSettings.number exists and checking if it is a number
	if (pSettings.number && Util.isNumber(pSettings.number))
		generator.settings.number = pSettings.number

	//Interface
	if (pSettings.interfaceInfo)
		generator.settings.interfaceInfo = pSettings.interfaceInfo

	if (pSettings.pauseEnd)
		generator.settings.pauseEnd = true

	// Plane
	if (pSettings.plane || pSettings.plane === 0)
		if (Util.isObject(pSettings.plane))
			if (Util.isNumber(pSettings.plane?.randomBetween[0]) && Util.isNumber(pSettings.plane?.randomBetween[1]))
				generator.settings.plane = pSettings.plane
			else
				// warning that this is a invalid variable type for this variable

		else if (Util.isNumber(pSettings.plane))
			generator.settings.plane = pSettings.plane
		else
			// warning that this is a invalid variable type for this variable

	// Layer
	if (pSettings.layer || pSettings.layer === 0)
		if (Util.isObject(pSettings.layer))
			if (Util.isNumber(pSettings.layer?.randomBetween[0]) && Util.isNumber(pSettings.layer?.randomBetween[1]))
				generator.settings.layer = pSettings.layer
			else
				// warning that this is a invalid variable type for this variable

		else if (Util.isNumber(pSettings.layer))
			generator.settings.layer = pSettings.layer
		else
			// warning that this is a invalid variable type for this variable

	// Loop
	if (!pSettings.loop)
		generator.settings.loop = false
	else
		generator.settings.loop = pSettings.loop

	// Pausable
	if (pSettings.pausable)
		generator.settings.pausable = true

	// Check if pSettings.duration exists and checking if it is a number
	if (pSettings.duration && Util.isNumber(pSettings.duration))
		generator.settings.duration = pSettings.duration

	// Check if pSettings.padding exists and checking if it is a number
	if (pSettings.padding)
		if (Util.isNumber(pSettings.padding))
			generator.settings.padding = pSettings.padding

		// If pSettings.padding is a object
		else if (Util.isObject(pSettings.padding))
			if (Util.isNumber(pSettings.padding?.randomBetween[0]) && Util.isNumber(pSettings.padding?.randomBetween[1]))
				generator.settings.padding = pSettings.padding
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable

	// Check if pSettings.texture exists
	if (pSettings.texture)
		// Checking if pSettings.texture is a valid texture, or if it has a type and its not a `Object`.
		if (validTextures.includes(pSettings.texture) || (pSettings.texture.type && pSettings.texture.baseType !== 'Object'))
			generator.settings.texture = pSettings.texture
		else if (Util.isArray(pSettings.texture))
			for (let i = pSettings.texture.length - 1; i >= 0; i--)
				if (validTextures.includes(pSettings.texture[i]))
					continue
				pSettings.texture.splice(i, 1)
				JS.console.warn('aParticleGenerator[texture]: Invalid variable %ctexture', 'font-weight: bold', '(' + pSettings.texture[i] + ') passed in the texture array. It has been removed. This may be a texture that has failed to load properly.')
			generator.settings.texture = pSettings.texture
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this was not passed and the default of `particle` has been used

	// Check if there is a composite set to use
	if (pSettings.composite)
		if (Util.isString(pSettings.composite))
			// Check if this is a valid composite
			if (validComposites.includes(pSettings.composite))
				generator.settings.composite = pSettings.composite
			else
				JS.console.warn('aParticleGenerator[composite]: Invalid variable %ccomposite', 'font-weight: bold', '(' + pSettings.composite + ') passed in the composite property. Default value used.')
		else
			// warning that this is a invalid variable type for this variable

	if (pSettings.light)
		if (aLight)
			if (Util.isObject(pSettings.light))
				if (pSettings.light.color)
					if (Util.isNumber(pSettings.light.color) || Util.isString(pSettings.light.color))
						generator.settings.light.color = aUtils.grabColor(pSettings.light.color).decimal
					else
						JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.color', 'font-weight: bold', 'property.');

				if (pSettings.light.size)
					if (Util.isNumber(pSettings.light.size))
						generator.settings.light.size = pSettings.light.size
					else
						JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.size', 'font-weight: bold', 'property.');

				if (pSettings.light.brightness)
					if (Util.isNumber(pSettings.light.brightness))
						generator.settings.light.brightness = pSettings.light.brightness
					else
						JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.brightness', 'font-weight: bold', 'property.');

				if (pSettings.light.offset)
					if (Util.isNumber(pSettings.light.offset))
						generator.settings.light.offset.x = pSettings.light.offset
						generator.settings.light.offset.y = pSettings.light.offset
					else if (Util.isObject(pSettings.light.offset))
						if (Util.isNumber(pSettings.light.offset.x) && Util.isNumber(pSettings.light.offset.y))
							generator.settings.light.offset.x = pSettings.light.offset.x
							generator.settings.light.offset.y = pSettings.light.offset.y
						else
							JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.offset.x || pSettings.light.offset.y', 'font-weight: bold', 'property.');
					else
						JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.offset', 'font-weight: bold', 'property.');

				// num or object with `x` and `y` as numbers
				if (pSettings.light.cullDistance)
					if (Util.isNumber(pSettings.light.cullDistance))
						generator.settings.light.cullDistance.x = pSettings.light.cullDistance / Client.mapView.scale.x;
						generator.settings.light.cullDistance.y = pSettings.light.cullDistance / Client.mapView.scale.y;
					else if (Util.isObject(pSettings.light.cullDistance))
						if (Util.isNumber(pSettings.light.cullDistance.x) && Util.isNumber(pSettings.light.cullDistance.y))
							generator.settings.light.cullDistance.x = pSettings.light.cullDistance.x / Client.mapView.scale.x;
							generator.settings.light.cullDistance.y = pSettings.light.cullDistance.y / Client.mapView.scale.y;
						else
							JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.cullDistance.x || pSettings.light.cullDistance.y', 'font-weight: bold', 'property.');
					else
						JS.console.warn('aParticleGenerator: Invalid variable type passed for the %cpSettings.light.cullDistance', 'font-weight: bold', 'property.');		

				// num or object with `x` and `y` as numbers
				if (pSettings.light.fadeDistance)
					if (Util.isNumber(pSettings.light.fadeDistance))
						generator.settings.light.fadeDistance.x = pSettings.light.fadeDistance / Client.mapView.scale.x;
						generator.settings.light.fadeDistance.y = pSettings.light.fadeDistance / Client.mapView.scale.y;
						if (generator.settings.light.fadeDistance.x > generator.settings.light.cullDistance.x || generator.settings.light.fadeDistance.y > generator.settings.light.cullDistance.y)
							if (this.debugging) console.warn('aLight: %cpSettings.light.fadeDistance', 'font-weight: bold', 'is greater than pSettings.light.cullDistance. pSettings.light.fadeDistance will not work as expected.');	
					else if (Util.isObject(pSettings.light.fadeDistance))
						if (Util.isNumber(pSettings.light.fadeDistance.x) && Util.isNumber(pSettings.light.fadeDistance.y))
							generator.settings.light.fadeDistance.x = pSettings.light.fadeDistance.x / Client.mapView.scale.x;
							generator.settings.light.fadeDistance.y = pSettings.light.fadeDistance.y / Client.mapView.scale.y;
							if (generator.settings.light.fadeDistance.x > generator.settings.light.cullDistance.x || generator.settings.light.fadeDistance.y > generator.settings.light.cullDistance.y)
								if (this.debugging) console.warn('aLight: %cpSettings.light.fadeDistance', 'font-weight: bold', 'is greater than pSettings.light.cullDistance. pSettings.light.fadeDistance will not work as expected.');
						else
							JS.console.warn('aLight: Invalid variable type passed for the %cpSettings.light.fadeDistance.x || pSettings.light.fadeDistance.y', 'font-weight: bold', 'property.');
					else
						JS.console.warn('aLight: Invalid variable type passed for the %cpSettings.light.fadeDistance', 'font-weight: bold', 'property.');	

				generator.usingLights = true
			else
				// warning that this is a invalid variable type for this variable
		else
			JS.console.error('aParticleGenerator[light]: The %caLight', 'font-weight: bold', 'library is missing. Please obtain it from https://github.com/aHouseStudio/aLight')

	let plane
	let usingOutline = false
	let usingBloom = false
	// Check if there is a outlineFilter being used
	if (pSettings.outlineFilter)
		if (JS.PIXI.filters.OutlineFilter)		
			if (Util.isObject(pSettings.outlineFilter))
				// if you already have a plane set it is overwritten, due to this filter needing its own plane as to not disturb the rest of the things on the plane you have provided.
				// this plane is of high value so it is preset to be ontop of everything else. Maybe in the future i will allow this to be changed?
				plane = OUTLINE_PLANE
				
				generator.settings.outlineFilter.ignorePlane = pSettings.outlineFilter.ignorePlane

				if (!pSettings.outlineFilter.ignorePlane)
					if (Client.getPlane(plane))
						while (Client.getPlane(plane))
							plane++

				if (pSettings.outlineFilter.thickness || pSettings.outlineFilter.thickness === 0)
					if (Util.isNumber(pSettings.outlineFilter.thickness))
						generator.settings.outlineFilter.thickness = pSettings.outlineFilter.thickness
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.outlineFilter.color || pSettings.outlineFilter.color === 0)
					// hex and decimal only
					if (Util.isNumber(pSettings.outlineFilter.color) || Util.isString(pSettings.outlineFilter.color))
						generator.settings.outlineFilter.color = aUtils.grabColor(pSettings.outlineFilter.color).decimal
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.outlineFilter.quality || pSettings.outlineFilter.quality === 0)
					if (Util.isNumber(pSettings.outlineFilter.quality))
						if (generator.debugging && pSettings.outlineFilter.quality > 0.5)
							JS.console.warn('aParticleGenerator[outlineFilter]: Using a higher %cquality', 'font-weight: bold', 'setting will result in slower performance and more accuracy.')
						generator.settings.outlineFilter.quality = Math.clamp(pSettings.outlineFilter.quality, 0, 1)
					else
						// warning that this is a invalid variable type for this variable

				usingOutline = true
		else
			JS.console.error('aParticleGenerator[outlineFilter]: The %cpixiJS filters', 'font-weight: bold', 'library is missing. Please obtain it from https://www.npmjs.com/package/pixi-filters')

	// Check if there is a bloomFilter being used
	if (pSettings.bloomFilter)
		if (JS.PIXI.filters.AdvancedBloomFilter)
			if (Util.isObject(pSettings.bloomFilter))
				// if you already have a plane set it is overwritten, due to this filter needing its own plane as to not disturb the rest of the things on the plane you have provided.
				// this plane is of high value so it is preset to be ontop of everything else. Maybe in the future i will allow this to be changed?
				plane = BLOOM_PLANE
				
				if (generator.outlinePlane)
					plane = BLOOM_OUTLINE_PLANE

				generator.settings.bloomFilter.ignorePlane = pSettings.bloomFilter.ignorePlane

				if (!pSettings.bloomFilter.ignorePlane)
					if (Client.getPlane(plane))
						while (Client.getPlane(plane))
							plane++

				if (pSettings.bloomFilter.threshold || pSettings.bloomFilter.threshold === 0)
					if (Util.isNumber(pSettings.bloomFilter.threshold))
						generator.settings.bloomFilter.threshold = pSettings.bloomFilter.threshold
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.bloomFilter.bloomScale || pSettings.bloomFilter.bloomScale === 0)
					if (Util.isNumber(pSettings.bloomFilter.bloomScale))
						generator.settings.bloomFilter.bloomScale = pSettings.bloomFilter.bloomScale
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.bloomFilter.brightness || pSettings.bloomFilter.brightness === 0)
					if (Util.isNumber(pSettings.bloomFilter.brightness))
						generator.settings.bloomFilter.brightness = pSettings.bloomFilter.brightness
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.bloomFilter.blur || pSettings.bloomFilter.blur === 0)
					if (Util.isNumber(pSettings.bloomFilter.blur))
						generator.settings.bloomFilter.blur = pSettings.bloomFilter.blur
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.bloomFilter.quality || pSettings.bloomFilter.quality === 0)
					if (Util.isNumber(pSettings.bloomFilter.quality))
						generator.settings.bloomFilter.quality = pSettings.bloomFilter.quality
					else
						// warning that this is a invalid variable type for this variable
/* 
				if (pSettings.bloomFilter.kernels || pSettings.bloomFilter.kernels === 0)
					if (Util.isNumber(pSettings.bloomFilter.kernels))
						generator.settings.bloomFilter.kernels = pSettings.bloomFilter.kernels
					else
						// warning that this is a invalid variable type for this variable
*/
				if (pSettings.bloomFilter.pixelSize || pSettings.bloomFilter.pixelSize === 0)
					if (Util.isNumber(pSettings.bloomFilter.pixelSize))
						generator.settings.bloomFilter.pixelSize = pSettings.bloomFilter.pixelSize
					else
						// warning that this is a invalid variable type for this variable

				if (pSettings.bloomFilter.resolution || pSettings.bloomFilter.resolution === 0)
					if (Util.isNumber(pSettings.bloomFilter.resolution))
						generator.settings.bloomFilter.resolution = pSettings.bloomFilter.resolution
					else
						// warning that this is a invalid variable type for this variable

				usingBloom = true
		else
			JS.console.error('aParticleGenerator[bloomFilter]: The %cpixiJS filters', 'font-weight: bold', 'library is missing. Please obtain it from https://www.npmjs.com/package/pixi-filters')		

	if (plane)
		generator.settings.plane = plane
		Client.setPlane(plane)
		if (usingOutline && usingBloom)
			// since this outlineFilter and the bloomFilter is being used there will be a special plane created so that plane can use the outline filter.
			generator.bloomOutlinePlane = Client.getPlane(plane)
			generator.bloomOutlinePlane.addFilter('outlineFilter', 'custom', { 'filter': new JS.PIXI.filters.OutlineFilter(generator.settings.outlineFilter.thickness, generator.settings.outlineFilter.color, generator.settings.outlineFilter.quality) })
			generator.bloomOutlinePlane.addFilter('bloomFilter', 'custom', { 'filter': new JS.PIXI.filters.AdvancedBloomFilter({ 'threshold': generator.settings.bloomFilter.threshold, 'bloomScale': generator.settings.bloomFilter.bloomScale, 'brightness': generator.settings.bloomFilter.brightness, 'blur': generator.settings.bloomFilter.blur, 'quality': generator.settings.bloomFilter.quality, 'kernels': generator.settings.bloomFilter.kernels, 'pixelSize': generator.settings.bloomFilter.pixelSize, 'resolution': generator.settings.bloomFilter.resolution })})
		else if (usingOutline)
			// since this outlineFilter is being used there will be a special plane created so that plane can use the outline filter.
			generator.outlinePlane = Client.getPlane(plane)
			generator.outlinePlane.addFilter('outlineFilter', 'custom', { 'filter': new JS.PIXI.filters.OutlineFilter(generator.settings.outlineFilter.thickness, generator.settings.outlineFilter.color, generator.settings.outlineFilter.quality) })

		else if (usingBloom)
			// since this bloomFilter is being used there will be a special plane created so that plane can use the outline filter.
			generator.bloomPlane = Client.getPlane(plane)
			generator.bloomPlane.addFilter('bloomFilter', 'custom', { 'filter': new JS.PIXI.filters.AdvancedBloomFilter({ 'threshold': generator.settings.bloomFilter.threshold, 'bloomScale': generator.settings.bloomFilter.bloomScale, 'brightness': generator.settings.bloomFilter.brightness, 'blur': generator.settings.bloomFilter.blur, 'quality': generator.settings.bloomFilter.quality, 'kernels': generator.settings.bloomFilter.kernels, 'pixelSize': generator.settings.bloomFilter.pixelSize, 'resolution': generator.settings.bloomFilter.resolution })})
	
	// Check if pSettings.orientation exists and if it is a string
	if (pSettings.orientation && Util.isString(pSettings.orientation))
		generator.settings.orientation = pSettings.orientation
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.angleOverLifetime exists and checking if it is a number
	if (pSettings.angleOverLifetime || pSettings.angleOverLifetime === 0 && Util.isNumber(pSettings.angleOverLifetime))
		generator.settings.angleOverLifetime = pSettings.angleOverLifetime
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.alphaOverLifetime exists and checking if it is a function
	if (pSettings.alphaOverLifetime && Util.getVariableType(pSettings.alphaOverLifetime) === 'function')
		generator.settings.alphaOverLifetime = pSettings.alphaOverLifetime
	else
		// warning that this is a invalid variable type for this variable

	// Check if settings.colorOverLifetime exists and checking if it is string, object, or number
	if (pSettings.colorOverLifetime)
		if (Util.isString(pSettings.colorOverLifetime))
			generator.settings.colorOverLifetime = pSettings.colorOverLifetime
		else if (Util.isObject(pSettings.colorOverLifetime))
			if (Util.isString(pSettings.colorOverLifetime?.randomBetween[0]) && Util.isString(pSettings.colorOverLifetime?.randomBetween[1]))
				generator.settings.colorOverLifetime = pSettings.colorOverLifetime
			else
				// warning that this is a invalid variable type for this variable
		else if (Util.isNumber(pSettings.colorOverLifetime))
			generator.settings.colorOverLifetime = pSettings.colorOverLifetime
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.sizeOverTime exists and checking if it is a function
	if (pSettings.sizeOverTime && Util.getVariableType(pSettings.sizeOverTime) === 'function')
		generator.settings.sizeOverTime = pSettings.sizeOverTime
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.speedOverTime exists and checking if it is a function
	if (pSettings.speedOverTime && Util.getVariableType(pSettings.speedOverTime) === 'function')
		generator.settings.speedOverTime = pSettings.speedOverTime
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.startColor exists
	if (pSettings.startColor)
		// If pSettings.startColor is a number
		if (Util.isString(pSettings.startColor))
			generator.settings.startColor = pSettings.startColor
		
		// If pSettings.startColor is a object
		else if (Util.isObject(pSettings.startColor))
			if (Util.isString(pSettings.startColor?.randomBetween[0]) && Util.isString(pSettings.startColor?.randomBetween[1]))
				generator.settings.startColor = pSettings.startColor
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable
	
	// Check if pSettings.startLifetime exists
	if (pSettings.startLifetime || pSettings.startLifetime === 0)
		// If pSettings.startLifetime is a number
		if (Util.isNumber(pSettings.startLifetime))
			generator.settings.startLifetime = pSettings.startLifetime
		
		// If pSettings.startLifetime is a object
		else if (Util.isObject(pSettings.startLifetime))
			if (Util.isNumber(pSettings.startLifetime?.randomBetween[0]) && Util.isNumber(pSettings.startLifetime?.randomBetween[1]))
				generator.settings.startLifetime = pSettings.startLifetime
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.startAngle exists
	if (pSettings.startAngle || pSettings.startAngle === 0)
		// If pSettings.startAngle is a number
		if (Util.isNumber(pSettings.startAngle))
			generator.settings.startAngle = pSettings.startAngle
		
		// If pSettings.startAngle is a object
		else if (Util.isObject(pSettings.startAngle))
			if (Util.isNumber(pSettings.startAngle?.randomBetween[0]) && Util.isNumber(pSettings.startAngle?.randomBetween[1]))
				generator.settings.startAngle = pSettings.startAngle
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.startSize exists
	if (pSettings.startSize || pSettings.startSize === 0)
		// If pSettings.startSize is a number
		if (Util.isNumber(pSettings.startSize))
			generator.settings.startSize = pSettings.startSize
		
		// If pSettings.startSize is a object
		else if (Util.isObject(pSettings.startSize))
			if (Util.isNumber(pSettings.startSize?.randomBetween[0]) && Util.isNumber(pSettings.startSize?.randomBetween[1]))
				generator.settings.startSize = pSettings.startSize
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.startSpeed exists
	if (pSettings.startSpeed || pSettings.startSpeed === 0)
		// If pSettings.startSpeed is a number
		if (Util.isNumber(pSettings.startSpeed))
			generator.settings.startSpeed = pSettings.startSpeed
		
		// If pSettings.startSpeed is a object
		else if (Util.isObject(pSettings.startSpeed))
			if (Util.isNumber(pSettings.startSpeed?.randomBetween[0]) && Util.isNumber(pSettings.startSpeed?.randomBetween[1]))
				generator.settings.startSpeed = pSettings.startSpeed
			else
				// warning that this is a invalid variable type for this variable
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.startAlpha exists and checking if it is a number or a string, if it is a string it must be === to'random'
	if (pSettings.startAlpha || pSettings.startAlpha === 0)
		if (Util.isNumber(pSettings.startAlpha) || Util.isString(pSettings.startAlpha) && pSettings.startAlpha === 'random')
			generator.settings.startAlpha = pSettings.startAlpha
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.endAlpha exists and checking if it is a number or a string, if it is a string it must be === to 'random
	if (pSettings.endAlpha || pSettings.endAlpha === 0)
		if (Util.isNumber(pSettings.endAlpha) || Util.isString(pSettings.endAlpha) && pSettings.endAlpha === 'random')
			generator.settings.endAlpha = pSettings.endAlpha
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.endSpeed exists
	if (pSettings.endSpeed || pSettings.endSpeed === 0)
		// If pSettings.endSpeed is a number
		if (Util.isNumber(pSettings.endSpeed))
			generator.settings.endSpeed = pSettings.endSpeed

		// If pSettings.endSpeed is a object
		else if (Util.isObject(pSettings.endSpeed))
			if (Util.isNumber(pSettings.endSpeed?.randomBetween[0]) && Util.isNumber(pSettings.endSpeed?.randomBetween[1]))
				generator.settings.endSpeed = pSettings.endSpeed
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.endSize exists
	if (pSettings.endSize || pSettings.endSize === 0)
		// If pSettings.endSize is a number
		if (Util.isNumber(pSettings.endSize))
			generator.settings.endSize = pSettings.endSize
			
		// If pSettings.endSize is a object
		else if (Util.isObject(pSettings.endSize))
			if (Util.isNumber(pSettings.endSize?.randomBetween[0]) && Util.isNumber(pSettings.endSize?.randomBetween[1]))
				generator.settings.endSize = pSettings.endSize
		else
			// warning that this is a invalid variable type for this variable
	else
		// warning that this is a invalid variable type for this variable

	// Check if pSettings.mapInfo exist and checking if it is a ojbect, also checking if the vars inside are of the right type
	if (pSettings.mapInfo && Util.isObject(pSettings.mapInfo))
		if (pSettings.mapInfo?.offset)
			if (Util.isObject(pSettings.mapInfo.offset))
				if (Util.isNumber(pSettings.mapInfo.offset?.x) && Util.isNumber(pSettings.mapInfo.offset?.y))
					generator.settings.mapInfo.offset.x = pSettings.mapInfo.offset.x
					generator.settings.mapInfo.offset.y = pSettings.mapInfo.offset.y
				else
					// warning that the values were of a invalid variable type for this object

		if (pSettings.mapInfo?.useEmitterDirection)
			generator.settings.mapInfo.useEmitterDirection = true

		if (pSettings.mapInfo?.useInverseDirection)
			generator.settings.mapInfo.useInverseDirection = true

		if (Util.isNumber(pSettings.mapInfo?.xPos) && Util.isNumber(pSettings.mapInfo?.yPos) && Util.isString(pSettings.mapInfo?.mapName))
			generator.settings.mapInfo = pSettings.mapInfo
			if (pSettings.mapInfo?.useEmitterPos)
				// Warning that you used set it to use the emitters's position but you also supplied valid positions. Supplied positions have higher priority and these are used.
				generator.settings.mapInfo.useEmitterPos = false

		else if (pSettings.mapInfo?.useEmitterPos)
			generator.settings.mapInfo.useEmitterPos = true

		else
			// Warning that you supplied a object, but the vars were invalid or missing.

	// If the generator is set to playOnCreation and there is no startDelay
	if (pSettings.playOnCreation && !pSettings.startDelay)
		// Assign variable values
		generator.settings.playOnCreation = true
		generator.settings.startDelay = 0
		// Start it !
		generator.start()
	// If the generator is to playOnCreation and there IS a startDelay
	else if (pSettings.playOnCreation && pSettings.startDelay)
		// Assign variable values
		generator.settings.playOnCreation = true
		generator.settings.startDelay = 0 // should be true (or a value), however as `playOnCreation` has more priority, this has been overrided
		// Start it !
		generator.start()
		// Display Warning
		// Play on creation was set to true, however `startDelay` also had a value, these options conflict with each other and as `playOnCreation` has more priority, it has been used
	// If the generator is NOT to playOnCreation and there IS a startDelay
	else if (!pSettings.playOnCreation && pSettings.startDelay)
		// Assign variable values
		generator.settings.playOnCreation = false
		generator.settings.startDelay = pSettings.startDelay
		// Add it to the ticker so it can begin counting down the delay until it can start
		Event.addTicker(generator)

	else if (pSettings.playOnCreation)
		generator.settings.playOnCreation = true
		generator.settings.startDelay = 0
		generator.start()

	return generator

function destroyParticleGenerator(pGenerator)
	pGenerator.destroy(true)

ParticleGenerator
	// This is a array that holds all map based particles generated by the generator
	let mapBasedParticles = []
	// This is a array that holds all screen based particles generated by the generator
	let screenBasedParticles = []
	// The owner of this generator if there is one.
	let owner = null
	// this is a reference to the plane this generator is using for its outline filter
	let outlinePlane
	// this is a reference to the plane this generator is using for its bloom filter
	let bloomPlane
	// this is a reference to the plane this generator is using for its outline and bloom filter
	let bloomOutlinePlane
	// this is a boolean depicting if this generator is using lights
	let usingLights = false
	// debugging is whether this generator is in debug mode. Extra warnings will be thrown in this mode to help explain any issues that may arise.
	let debugging = false
	// This is a object that holds various settings for the particle generator
	let settings = {
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
		// padding can be a integer depicting the padding between the origin
		'padding': 0, // rename this?
		// texture can be a diob to get the appearance of, or an valid iconName inside of particle_atlas
		'texture': 'particle',
		// composite can be any valid composite value
		'composite': '',
 		// light is if each particle will have a light attached to it. THIS CAN ONLY BE USED IF THE LIBRARY `aLight` is included
		'light': { 'color': 0xFFFFFF, 'size': 5, 'brightness': 5, 'offset': { 'x': 0, 'y': 0 }, 'cullDistance': {}, 'fadeDistance': {} }, 
		// outline filter with it's settings
		'outlineFilter': { 'thickness': 1, 'color': 0x000000, 'quality': 0.1, 'ignorePlane': false },
 		// bloom filter with it's settings
		'bloomFilter': { 'threshold': 0.5, 'bloomScale': 1, 'brightness': 1, 'blur': 1, 'quality': 4, 'kernels': null, 'pixelSize': 1, 'resolution': 1, 'ignorePlane': false },
		// orientation is the orientation in which the particles line up in, these are directional values, and `none` should be use for diobs to flow freely
		'orientation': 'south',
		// angleOverLifetime is the angle velocity in degrees in a update tick 10ms
		'angleOverLifetime': 0,
		// alphaOverLifetime is a beziercurve function depicting the alpha over the lifetime
		'alphaOverLifetime': null,
		// colorOverLifetime is an hex or an decimal with the color the particle should be at the end of its lifetime rgbString.match(/\d+/g) (formula)
		'colorOverLifetime': null,
		// sizeOverLifetime is a bezier curve defining the particiles size over its lifetime
		'sizeOverLifetime': null,
		// speedOverLifetime is a beziercurve function depicting the curve and the speed over the lifetime
		'speedOverLifetime': null,
		// startDelay is the delay in ms before the particle generator starts. If this is set and playOnCreation is true, playOnCreation is ignored.
		'startDelay': 0,
		// startColor can be a hex or a decimal or a object containing two colors to pick a random color between 'startColor': { 'randomBetween': [hexOrRGB, hexOrRGB] }
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
		// emitter is the diob that owns this particle generator. This variable is preset when `diob.attachParticleGenerator` is called. `diob` is emitter
		'emitter': null,
		// mapInfo is an object with information on where to put the "particle generator"
		'mapInfo': { 'xPos': 0, 'yPos': 0, 'mapName': '', 'useEmitterPos': false, 'useEmitterDirection': false, 'useInverseDirection': false, 'offset': { 'x': 0, 'y': 0 } },
		// interfaceInfo is an object with information on where to put the particle generator in the interface
		'interfaceInfo': { 'xPos': 0, 'yPos': 0, 'interface': '' },
		// plane is the plane that will be set for the ParticleGenerator
		'plane': MAX_PLANE,
		// layer is the layer that will be set for the ParticleGenerator
		'layer': MAX_PLANE,
		// id is set when using `attachParticleGenerator` it is the identifier for this generator. READONLY
		'id': null
	}

	onTick(pT)
		if (!this.settings.paused)
			if (this.settings.startDelay)
				this.settings.startDelay = Math.clamp(this.settings.startDelay - PARTICLE_GENERATOR_TICK_RATE, 0, this.settings.startDelay)
				if (!this.settings.startDelay)
					this.start()
			else
				if (this.settings.active)
					if (this.screenBasedParticles.length)
						foreach (let particle in this.screenBasedParticles)
							this.update(particle)

					if (this.mapBasedParticles.length)
						foreach (let particle in this.mapBasedParticles)
							this.update(particle)
				else
					if (!this.settings.paused)
						this.destroy(true)

	function setup()
		LIBRARY_activeGenerators.push(this)

	onNew()
		this.setup()

	function onDumped()
		this.setup()

	onDel()
		this.destroy()
		
	function reset()
		if (this.owner)
			// remove this generator from the owner's generator objects
			del Prop(this.owner.particleGenerators, this.settings.id)
			this.owner = null

		if (this.outlinePlane)
			if (!this.settings.outlineFilter.ignorePlane)
				foreach (let filter in this.outlinePlane.getFilters())
					this.outlinePlane.removeFilter(filter)

		if (this.bloomPlane)
			if (!this.settings.bloomFilter.ignorePlane)
				foreach (let filter in this.bloomPlane.getFilters())
					this.bloomPlane.removeFilter(filter)

		if (this.bloomOutlinePlane)
			if (!this.settings.bloomFilter.ignorePlane && !this.settings.outlineFilter.ignorePlane)
				foreach (let filter in this.bloomOutlinePlane.getFilters())
					this.bloomOutlinePlane.removeFilter(filter)

		if (this.mapBasedParticles.length)
			aRecycle.collect(this.mapBasedParticles, LIBRARY_mapParticleArray)

		if (this.screenBasedParticles.length)
			aRecycle.collect(this.screenBasedParticles, LIBRARY_screenParticleArray)

		this.owner = null
		this.usingLights = false
		this.outlinePlane = null
		this.bloomPlane = null
		this.bloomOutlinePlane = null
		this.mapBasedParticles = []
		this.screenBasedParticles = []
		this.settings = Type.getVariable(this.type, 'settings')
		Event.removeTicker(this)

	function generateParticles(pBypass)
		let displayType = (this.settings.interfaceInfo.interface ? 'screen' : 'map')
		if (displayType === 'map')
			this.mapBasedParticles = (this.settings.number === 1) ? [aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_mapParticleArray, false, this.settings, this, pBypass)] : aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_mapParticleArray, false, this.settings, this, pBypass)

		else if (displayType === 'screen')
			this.screenBasedParticles = (this.settings.number === 1) ? [aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_screenParticleArray, false, this.settings, this, pBypass)] : aRecycle.isInCollection('GeneratedParticle', this.settings.number, LIBRARY_screenParticleArray, false, this.settings, this, pBypass)

	function setActive(pElem)
		pElem.info.active = true

	function removeParticle(pParticle)
		pParticle.info.active = false
		pParticle.mapName = ''
		let properStorageArray = (pParticle.info.owner.settings.interfaceInfo.interface ? pParticle.info.owner.screenBasedParticles : pParticle.info.owner.mapBasedParticles)
		foreach (let particle in properStorageArray)
			if (particle.info.active)
				return
		if (this.settings.pauseEnd)
			this.pause()
			return
		this.destroy(true)

	function start()
		let generator = this
		let startGenerator = function()
			let update = generator.update.bind(generator)
			let properStorageArray = (generator.settings.interfaceInfo.interface ? generator.screenBasedParticles : generator.mapBasedParticles)
			generator.generateParticles()
			properStorageArray.forEach(generator.setActive)
			properStorageArray.forEach(update)
			// the generator is now active and all particles are active so this is now active
			generator.settings.active = true
			Event.addTicker(generator)

		Icon.cacheImage('particle_atlas', null, startGenerator)

	function destroy(pCollect)
		this.reset()
		if (pCollect)
			aRecycle.collect(this, LIBRARY_particleGenArray)
		if (LIBRARY_activeGenerators.includes(this))
			LIBRARY_activeGenerators.splice(LIBRARY_activeGenerators.indexOf(this), 1)
		
	function pause()
		// the generator is paused and all particles have been paused so this is now inactive
		this.settings.active = false
		this.settings.paused = true

	function resume()
		// the generator is unpaused and all particles have been unpaused so this is now active
		this.settings.active = true
		this.settings.paused = false
		let properStorageArray = (this.settings.interfaceInfo.interface ? this.screenBasedParticles : this.mapBasedParticles)
		properStorageArray.forEach(this.setActive)

	function setScaleOfParticle(pParticle, pLifetimePercent)
		if (pParticle.info.sizeOverLifetime && (pParticle.info.eSize || pParticle.info.eSize === 0))
			let startSize = (pParticle.info.startSize?.randomBetween ? pParticle.info.sSize : pParticle.info.startSize)
			pParticle.scale.x = (startSize > pParticle.info.eSize ? startSize - pParticle.info.sizeOverLifetime(pLifetimePercent) * (pParticle.info.eSize ? startSize - pParticle.info.eSize : startSize) : (startSize - pParticle.info.sizeOverLifetime(pLifetimePercent) * (startSize - pParticle.info.eSize))) // try to cycle the eSize and eSize
			pParticle.scale.y = pParticle.scale.x
			pParticle.scale = pParticle.scale
			return true

	function setAlphaOfParticle(pParticle, pLifetimePercent)
		if (pParticle.info.alphaOverLifetime && (pParticle.info.eAlpha || pParticle.info.eAlpha === 0))
			// if pParticle.info.startAlpha is `random`
			// startAlpha is to assume the startAlpha position, this is to take care of `random` startAlpha
			let startAlpha = (pParticle.info.startAlpha === 'random' ? pParticle.info.sAlpha : pParticle.info.startAlpha)
			pParticle.alpha = (startAlpha > pParticle.info.eAlpha ? startAlpha - pParticle.info.alphaOverLifetime(pLifetimePercent) * (pParticle.info.eAlpha ? startAlpha - pParticle.info.eAlpha : startAlpha) : (startAlpha - pParticle.info.alphaOverLifetime(pLifetimePercent) * (startAlpha - pParticle.info.eAlpha)))
			return true

	function setSpeedOfParticle(pParticle, pLifetimePercent)
		if (pParticle.info.speedOverLifetime && (pParticle.info.eSpeed || pParticle.info.eSpeed === 0))
			let startSpeed = (pParticle.info.startSpeed?.randomBetween ? pParticle.info.sSpeed : pParticle.info.startSpeed)
			pParticle.info.speed = (startSpeed > pParticle.info.eSpeed ? startSpeed - pParticle.info.speedOverLifetime(pLifetimePercent) * (pParticle.info.eSpeed ? startSpeed - pParticle.info.eSpeed : startSpeed) : (startSpeed - (pParticle.info.speedOverLifetime(pLifetimePercent) * Client.timeScale) * (startSpeed - pParticle.info.eSpeed)))
			return true

	function update(pParticle)
		if (pParticle)
			pParticle.info.lifetime += PARTICLE_GENERATOR_TICK_RATE * Client.timeScale /* PINGABLE */
			Client.getScreenPos(Client._pg_screenPos)
			pParticle.getScreenPos(pParticle._screenPos)
			// have to check if the particle is on the screen because `onScreenShow` and `onScreenHide` does not work well for particles since they are always considered to be shown.
			// pParticle.info.active = ((pParticle._screenPos.x >= Client._pg_screenPos.x && pParticle._screenPos.x <= Client._pg_screenPos.x + Client._pg_gameSize.width) || (pParticle._screenPos.y >= Client._pg_screenPos.y && pParticle._screenPos.y <= Client._pg_screenPos.y + Client._pg_gameSize.height)) ? true : false		
			if (pParticle.info.active)
				// if this particle is active, make it renderable again
				pParticle.sprite.renderable = true
				let lifetimePercent = pParticle.info.lifetime / pParticle.info.duration
				this.setScaleOfParticle(pParticle, lifetimePercent)
				this.setAlphaOfParticle(pParticle, lifetimePercent)
				this.setSpeedOfParticle(pParticle, lifetimePercent)
				pParticle.angle += Util.toRadians(pParticle.info.angleOverLifetime * Client.timeScale)
				if (Util.toDegrees(pParticle.angle) >= 360)
					pParticle.angle = 0
				if (pParticle.info.emitter)
					// Update Particle's orientation if it is supposed to match the emitters direciton
					if (pParticle.info.mapInfo?.useEmitterDirection)
						pParticle.info.orientation = (pParticle.info.mapInfo?.useInverseDirection ? pParticle.getInverseDir(pParticle.info.emitter.dir) : pParticle.info.emitter.dir)
				// Update Trajectory with speed and direction
				pParticle.setTrajectory()
				// Update Position after speed change
				if (pParticle.info.emitter)
					if (pParticle.info.mapInfo?.useEmitterPos)
						if (pParticle.info.emitter?.mapName)
							pParticle.setPos(pParticle.xPos + pParticle.info.trajectory.x, pParticle.yPos + pParticle.info.trajectory.y, pParticle.info.emitter.mapName)
				else
					if (pParticle.info.interfaceInfo.interface)
						pParticle.setPos(pParticle.xPos + pParticle.info.trajectory.x, pParticle.yPos + pParticle.info.trajectory.y)
					else				
						pParticle.setPos(pParticle.xPos + pParticle.info.trajectory.x, pParticle.yPos + pParticle.info.trajectory.y, pParticle.info.mapInfo.mapName)
			else
				// if the particle is not active, it does not need to be rendered
				pParticle.sprite.renderable = false
			// Reset if looping, remove if not
			if (pParticle.info.lifetime >= pParticle.info.duration)
				// reset the pParticle's render status to default
				pParticle.sprite.renderable = true
				let lifetimePercent
				// If the particle generator is set to loop then check all of the particles settings to see if anything needs to be randomized again
				if (this.settings.loop)
/* 					
					// Plane
					// this have been removed due to particles not being able to `relayer`. And changing it after it's been preset the first time presents unexpected behavior. So if layering is wanted, it can only be set once.		
					if (pParticle.info.plane)
						if (Util.isObject(pParticle.info.plane))
							pParticle.plane = aUtils.decimalRand(pParticle.info.plane.randomBetween[0], pParticle.info.plane.randomBetween[1])
						else
							pParticle.plane = pParticle.info.plane
					// Layer			
					if (pParticle.info.layer)
						if (Util.isObject(pParticle.info.layer))
							pParticle.layer = aUtils.decimalRand(pParticle.info.layer.randomBetween[0], pParticle.info.layer.randomBetween[1])
						else
							pParticle.layer = pParticle.info.layer 
*/
					// StartColor
					if (Util.isObject(pParticle.info.startColor))
						pParticle.color.tint = aUtils.grabColor(JS.getRandomColorBetween(pParticle.info.startColor.randomBetween[0], pParticle.info.startColor.randomBetween[1])).decimal
					else if (Util.isNumber(pParticle.info.startColor) || Util.isString(pParticle.info.startColor))
						if (Util.isString(pParticle.info.startColor) && pParticle.info.startColor === 'random')
							pParticle.color.tint = aUtils.grabColor().decimal
						else
							pParticle.color.tint = aUtils.grabColor(pParticle.info.startColor).decimal
					pParticle.color = pParticle.color
					// StartLifetime
					if (Util.isObject(pParticle.info.startLifetime))
						pParticle.info.lifetime = aUtils.decimalRand(pParticle.info.startLifetime.randomBetween[0], pParticle.info.startLifetime.randomBetween[1])
						lifetimePercent = pParticle.info.lifetime / pParticle.info.duration
					else
						pParticle.info.lifetime = pParticle.info.startLifetime
					// Padding
					if (Util.isObject(pParticle.info.storedPadding))
						// padding
						pParticle.info.padding = aUtils.decimalRand(pParticle.info.storedPadding.randomBetween[0], pParticle.info.storedPadding.randomBetween[1])
					// EndAlpha
					if (Util.isString(pParticle.info.endAlpha))
						// eAlpha
						pParticle.info.eAlpha = aUtils.decimalRand(0, 1)
					else
						pParticle.info.eAlpha = pParticle.info.endAlpha
					// EndSpeed
					if (Util.isObject(pParticle.info.endSpeed))
						// eSpeed
						pParticle.info.eSpeed = aUtils.decimalRand(pParticle.info.endSpeed.randomBetween[0], pParticle.info.endSpeed.randomBetween[1])
					else
						pParticle.info.eSpeed = pParticle.info.endSpeed
					// EndSize
					if (Util.isObject(pParticle.info.endSize))
						// eSize
						pParticle.info.eSize = aUtils.decimalRand(pParticle.info.endSize.randomBetween[0], pParticle.info.endSize.randomBetween[1])
					else
						pParticle.info.eSize = pParticle.info.endSize
					// StartAlpha
					if (Util.isString(pParticle.info.startAlpha))
						if (lifetimePercent) // means the lifetime is not natural
							this.setAlphaOfParticle(pParticle, lifetimePercent)
						else
							let alphaRand = aUtils.decimalRand(0, 1)
							// sAlpha
							pParticle.info.sAlpha = alphaRand
							pParticle.alpha = alphaRand
					else
						if (lifetimePercent) // means the lifetime is not natural
							this.setAlphaOfParticle(pParticle, lifetimePercent)
						else
							pParticle.alpha = pParticle.info.startAlpha
					// StartSize
					if (Util.isObject(pParticle.info.startSize))
						if (lifetimePercent) // means the lifetime is not natural
							this.setScaleOfParticle(pParticle, lifetimePercent)
						else
							// sSize
							let sizeRand = aUtils.decimalRand(pParticle.info.startSize.randomBetween[0], pParticle.info.startSize.randomBetween[1])
							pParticle.info.sSize = sizeRand
							pParticle.scale.x = pParticle.scale.y = sizeRand
					else
						if (lifetimePercent) // means the lifetime is not natural
							this.setScaleOfParticle(pParticle, lifetimePercent)
						else
							pParticle.scale.x = pParticle.scale.y = pParticle.info.startSize
					pParticle.scale = pParticle.scale
					// StartAngle
					if (Util.isObject(pParticle.info.startAngle))
						pParticle.angle = Util.toRadians(aUtils.decimalRand(pParticle.info.startAngle.randomBetween[0], pParticle.info.startAngle.randomBetween[1]))
					else
						pParticle.angle = Util.toRadians(pParticle.info.startAngle)
					//	StartSpeed
					if (Util.isObject(pParticle.info.startSpeed))
						if (lifetimePercent) // means the lifetime is not natural
							this.setSpeedOfParticle(pParticle, lifetimePercent)
						else
							let speedRand = aUtils.decimalRand(pParticle.info.startSpeed.randomBetween[0], pParticle.info.startSpeed.randomBetween[1])
							// sSpeed
							pParticle.info.sSpeed = speedRand
							pParticle.info.speed = speedRand
					else
						if (lifetimePercent) // means the lifetime is not natural
							this.setSpeedOfParticle(pParticle, lifetimePercent)
						else
							pParticle.info.speed = pParticle.info.startSpeed
					// ColorOverLifetime
					if (pParticle.info.colorOverLifetime)
						let colorOverLifetime
						if (Util.isObject(pParticle.info.colorOverLifetime))
							colorOverLifetime = aUtils.grabColor(JS.getRandomColorBetween(pParticle.info.colorOverLifetime.randomBetween[0], pParticle.info.colorOverLifetime.randomBetween[1])).hex
						else if (Util.isNumber(pParticle.info.colorOverLifetime) || Util.isString(pParticle.info.colorOverLifetime))
							if (Util.isString(pParticle.info.colorOverLifetime) && pParticle.info.colorOverLifetime === 'random')
								colorOverLifetime = aUtils.grabColor().hex
							else
								colorOverLifetime = pParticle.info.colorOverLifetime
						if (pParticle.color)
							let startColor = aUtils.grabColor(pParticle.color.tint).hex
							aUtils.transitionColor(pParticle, startColor, colorOverLifetime, pParticle.info.duration - pParticle.info.lifetime)
						else
							aUtils.transitionColor(pParticle, '#ffffff', colorOverLifetime, pParticle.info.duration - pParticle.info.lifetime)
					// Texture
					if (pParticle.info.texture)
						if (Util.isArray(pParticle.info.texture))
							pParticle.iconName = Util.pick(pParticle.info.texture)
					// Update TempAngle
					if (pParticle.info.orientation === 'none')
						pParticle.info.tempAngle.x = Math.random() * (Math.prob(50) ? 1 : - 1)
						pParticle.info.tempAngle.y = Math.random() * (Math.prob(50) ? 1 : - 1)
					// Update Particle's orientation if it is supposed to match the emitters direciton
					if (pParticle.info.emitter)
						if (pParticle.info.mapInfo?.useEmitterDirection)
							pParticle.info.orientation = (pParticle.info.mapInfo?.useInverseDirection ? pParticle.getInverseDir(pParticle.info.emitter.dir) : pParticle.info.emitter.dir)
					// SetTrajectory for speed and direction after loop
					pParticle.setTrajectory()
					// SetPosAfterLoop	
					if (pParticle.info.emitter)
						if (pParticle.info.mapInfo?.useEmitterPos)
							if (pParticle.info.emitter?.mapName)
								let randomPaddingX = Math.rand(pParticle.info.emitter.xPos - pParticle.info.padding, pParticle.info.emitter.xPos + pParticle.info.padding)
								let randomPaddingY = Math.rand(pParticle.info.emitter.yPos - pParticle.info.padding, pParticle.info.emitter.yPos + pParticle.info.padding)
								pParticle.setPos((randomPaddingX + pParticle.info.mapInfo.offset.x) + pParticle.info.trajectory.x, (randomPaddingY + pParticle.info.mapInfo.offset.y) + pParticle.info.trajectory.y, pParticle.info.emitter.mapName)
					else
						if (pParticle.info.interfaceInfo.interface)
							let randomPaddingX = Math.rand(pParticle.info.interfaceInfo.xPos - pParticle.info.padding, pParticle.info.interfaceInfo.xPos + pParticle.info.padding)
							let randomPaddingY = Math.rand(pParticle.info.interfaceInfo.yPos - pParticle.info.padding, pParticle.info.interfaceInfo.yPos + pParticle.info.padding)
							pParticle.setPos(randomPaddingX + pParticle.info.trajectory.x, randomPaddingY + pParticle.info.trajectory.y)
						else				
							let randomPaddingX = Math.rand(pParticle.info.mapInfo.xPos - pParticle.info.padding, pParticle.info.mapInfo.xPos + pParticle.info.padding)
							let randomPaddingY = Math.rand(pParticle.info.mapInfo.yPos - pParticle.info.padding, pParticle.info.mapInfo.yPos + pParticle.info.padding)
							pParticle.setPos(randomPaddingX + pParticle.info.trajectory.x, randomPaddingY + pParticle.info.trajectory.y, pParticle.info.mapInfo.mapName)
				else
					this.removeParticle(pParticle)

GeneratedParticle : inherit [Particle]
	atlasName = 'particle_atlas'
	plane = MAX_PLANE
	layer = MAX_PLANE
	scale = { 'x': 0.3, 'y': 0.3 }
	mouseOpacity = 0
	touchOpacity = 0
	color = { 'tint': 0xFFFFFF }
	// preventScreenRelayer = false
	// preventInterpolation = true
	textStyle = { 'fill': '#ffffff', 'fontSize': 10, 'fontFamiy': 'Arial' }
	let _screenPos = { 'x': 0, 'y': 0 }
	let info = {
		'duration': 0,
		'padding': 0,
		'storedPadding': null,
		'lifetime': 0,
		'speed': 0.5,
		'orientation': 'south',
		'tempAngle': { 'x': 0, 'y': 0 }, // This is not passed in but rather given as a means to store a `Math.random()` so that particle movement isn't finicky
		'texture': 'particle',
		'composite': '',
		'plane': MAX_PLANE,
		'layer': MAX_PLANE,
		'mapInfo': { 'x': 0, 'y': 0, 'mapName': '', 'useEmitterPos': false, 'useEmitterDirection': false, 'useInverseDirection': false, 'offset': { 'x': 0, 'y': 0 } },
		'interfaceInfo': { 'x': 0, 'y': 0, 'interface': '' },
		'emitter': null,
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

	onNew(pInfo, pOwner, pBypass)
		// World.log(this)
		this.setup(pInfo, pOwner, pBypass)

	function onDumped(pInfo, pOwner, pBypass)
		this.setup(pInfo, pOwner, pBypass)

	function clean()
		// manually cleaning each particle so a bunch of objects and variables don't need to be recreated. As the life of some particles are very short, so having to do that a bunch isn't very good for performance
		if (this.info?.owner?.usingLights)
			aLight.detachLight(this, this.id)
		if (this.info.interfaceInfo.interface)
			Client.removeInterfaceElement(this.info.interfaceInfo.interface, this.id, true)
		this.sprite.renderable = true
		this.atlasName = 'particle_atlas'
		this.iconName = ''
		this.color.tint = 0xFFFFFF
		this.color = this.color
		this.xPos = this.yPos = 0
		this.mapName = ''
		this.plane = this.layer = MAX_PLANE
		this.composite = ''
		this.info.composite = ''
		this.scale.x = this.scale.y = 0.3
		this.scale = this.scale
		this._screenPos.x = this._screenPos.y = 0
		this.info.duration = this.info.padding = this.info.lifetime = 0
		this.info.storedPadding = null
		this.info.speed = 0.5
		this.info.orientation = 'south'
		this.info.tempAngle.x = this.info.tempAngle.y = 0
		this.info.texture = 'particle'
		this.info.plane = this.info.layer = MAX_PLANE
		// mapInfo
		this.info.mapInfo.x = this.info.mapInfo.y = 0
		if (this.info.mapInfo.offset)
			this.info.mapInfo.offset.x = this.info.mapInfo.offset.y = 0
		this.info.mapInfo.mapName = ''
		this.info.mapInfo.useEmitterPos = this.info.mapInfo.useEmitterDirection = this.info.mapInfo.useInverseDirection = false
		// interfaceInfo
		this.info.interfaceInfo.x = this.info.interfaceInfo.y = 0
		this.info.interfaceInfo.interface = null
		this.info.emitter = null
		this.info.startColor = this.info.startAlpha = this.info.startLifetime = this.info.startAngle = this.info.startSize = this.info.startSpeed = null
		this.info.colorOverLifetime = this.info.alphaOverLifetime = this.info.angleOverLifetime = this.info.sizeOverLifetime = this.info.sizeOverLifetime = this.info.speedOverLifetime = null
		this.info.trajectory.x = this.info.trajectory.y = 0
		this.info.eSpeed = this.info.eSize = this.info.eAlpha = this.info.endSpeed = this.info.endSize = this.info.endAlpha = null
		this.info.sAlpha = this.info.sSpeed = this.info.sSize = null
		this.info.owner = null
		this.info.active = false

	function getInverseDir(pDir)
		if (pDir === 'south') return 'north'    
		if (pDir === 'north') return 'south'
		if (pDir === 'east') return 'west'
		if (pDir === 'west') return 'east'
		if (pDir === 'southeast') return 'northwest'    
		if (pDir === 'southwest') return 'northeast'
		if (pDir === 'northeast') return 'southwest'    
		if (pDir === 'northwest') return 'southeast'

	function setup(pInfo, pOwner, pBypass)
		this.name = this.id
		// you are just precreating some of these types, so no need to run the code just yet
		// this is so a interface particle doesn not gets its `onNew` called again since we use `Client.addInterfaceElement`
		if (pBypass)
			return
		// All data coming in has already been prechecked, we just need to grab and assign a few things
		let lifetimePercent
		// Duration
		this.info.duration = pInfo.duration
		// Padding
		if (pInfo.padding || pInfo.padding === 0)
			if (Util.isObject(pInfo.padding))
				this.info.padding = aUtils.decimalRand(pInfo.padding.randomBetween[0], pInfo.padding.randomBetween[1])
			else
				this.info.padding = pInfo.padding
		this.info.storedPadding = pInfo.padding
		// Orientation
		this.info.orientation = pInfo.orientation
		// Owner
		this.info.owner = pOwner
		// Active
		this.info.active = true
		// Texture
		if (pInfo.texture?.type)
			this.setAppearance(pInfo.texture)
		else if (Util.isArray(pInfo.texture))
			this.iconName = Util.pick(pInfo.texture)
		else
			this.iconName = pInfo.texture
		this.info.texture = pInfo.texture
		// Composite
		this.composite = pInfo.composite
		this.info.composite = pInfo.composite
		// MapInfo
		this.info.mapInfo = {}
		Util.copyObject(this.info.mapInfo, pInfo.mapInfo);
		// InterfaceInfo
		this.info.interfaceInfo = {}
		Util.copyObject(this.info.interfaceInfo, pInfo.interfaceInfo);
		// Plane
		if (pInfo.plane || pInfo.plane === 0)
			if (Util.isObject(pInfo.plane))
				this.plane = aUtils.decimalRand(pInfo.plane.randomBetween[0], pInfo.plane.randomBetween[1])
			else
				this.plane = pInfo.plane
			this.info.plane = pInfo.plane
		// Layer
		if (pInfo.layer || pInfo.layer === 0)
			if (Util.isObject(pInfo.layer))
				this.layer = aUtils.decimalRand(pInfo.layer.randomBetween[0], pInfo.layer.randomBetween[1])
			else
				this.layer = pInfo.layer
			this.info.layer = pInfo.layer
		// Lifetime
		if (Util.isObject(pInfo.startLifetime))
			this.info.lifetime = aUtils.decimalRand(pInfo.startLifetime.randomBetween[0], pInfo.startLifetime.randomBetween[1])
			// Percent
			lifetimePercent = this.info.lifetime / this.info.duration
		else
			this.info.lifetime = pInfo.startLifetime
		// StartLifetime
		this.info.startLifetime = pInfo.startLifetime
		// this.color
		if (Util.isObject(pInfo.startColor))
			this.color.tint = aUtils.grabColor(JS.getRandomColorBetween(pInfo.startColor.randomBetween[0], pInfo.startColor.randomBetween[1])).decimal
		else if (Util.isNumber(pInfo.startColor) || Util.isString(pInfo.startColor))
			if (Util.isString(pInfo.startColor) && pInfo.startColor === 'random')
				this.color.tint = aUtils.grabColor().decimal
			else
				this.color.tint = aUtils.grabColor(pInfo.startColor).decimal
		this.color = this.color
		// StartColor
		this.info.startColor = pInfo.startColor
		// ColorOverTime
		this.info.colorOverLifetime = pInfo.colorOverLifetime
		if (this.info.colorOverLifetime)
			let colorOverLifetime
			if (Util.isObject(pInfo.colorOverLifetime))
				colorOverLifetime = aUtils.grabColor(JS.getRandomColorBetween(pInfo.colorOverLifetime.randomBetween[0], pInfo.colorOverLifetime.randomBetween[1])).hex
			else if (Util.isNumber(pInfo.colorOverLifetime) || Util.isString(pInfo.colorOverLifetime))
				if (Util.isString(pInfo.colorOverLifetime) && pInfo.colorOverLifetime === 'random')
					colorOverLifetime = aUtils.grabColor().hex
				else
					colorOverLifetime = pInfo.colorOverLifetime
			if (this.color)
				let startColor
				if (this.color?.tint)
					startColor = aUtils.grabColor(this.color.tint).hex
				else
					startColor = '#FFFFFF'
				aUtils.transitionColor(this, startColor, colorOverLifetime, pInfo.duration - this.info.lifetime)
			else
				aUtils.transitionColor(this, '#FFFFFF', colorOverLifetime, pInfo.duration - this.info.lifetime)
		// AlphaOverLifetime
		this.info.alphaOverLifetime = pInfo.alphaOverLifetime
		// AngleOverLifetime
		this.info.angleOverLifetime = pInfo.angleOverLifetime
		// SizeOverTime
		this.info.sizeOverLifetime = pInfo.sizeOverLifetime
		// SpeedOverTime
		this.info.speedOverLifetime = pInfo.speedOverLifetime
		// StartAlpha		
		this.info.startAlpha = pInfo.startAlpha
		// StartSize
		this.info.startSize = pInfo.startSize
		// StartSpeed
		this.info.startSpeed = pInfo.startSpeed
		// StartAngle
		this.info.startAngle = pInfo.startAngle
		// eAlpha
		if (Util.isString(pInfo.endAlpha))
			this.info.eAlpha = aUtils.decimalRand(0, 1)
		else
			this.info.eAlpha = pInfo.endAlpha
		// EndAlpha
		this.info.endAlpha = pInfo.endAlpha
		// eSize
		if (Util.isObject(pInfo.endSize))
			this.info.eSize = aUtils.decimalRand(pInfo.endSize.randomBetween[0], pInfo.endSize.randomBetween[1])
		else
			this.info.eSize = pInfo.endSize
		// EndSize
		this.info.endSize = pInfo.endSize
		// eSpeed
		if (Util.isObject(pInfo.endSpeed))
			this.info.eSpeed = aUtils.decimalRand(pInfo.endSpeed.randomBetween[0], pInfo.endSpeed.randomBetween[1])
		else
			this.info.eSpeed = pInfo.endSpeed
		// EndSpeed
		this.info.endSpeed = pInfo.endSpeed
		// Alpha
		if (Util.isString(pInfo.startAlpha))
			if (lifetimePercent && pInfo.endAlpha)
				pOwner.setAlphaOfParticle(this, lifetimePercent)
			else
				let alphaRand = aUtils.decimalRand(0, 1)
				// sAlpha
				this.info.sAlpha = alphaRand
				this.alpha = alphaRand
		else
			if (lifetimePercent && pInfo.endAlpha)
				pOwner.setAlphaOfParticle(this, lifetimePercent)
			else
				this.alpha = pInfo.startAlpha
		// Size / Scale
		if (Util.isObject(pInfo.startSize))
			if (lifetimePercent && this.endSize)
				pOwner.setScaleOfParticle(this, lifetimePercent)
			else
				let sizeRand = aUtils.decimalRand(pInfo.startSize.randomBetween[0], pInfo.startSize.randomBetween[1])
				// sSize
				this.info.sSize = sizeRand
				this.scale.x = this.scale.y = sizeRand
		else
			if (lifetimePercent && this.endSize)
				pOwner.setScaleOfParticle(this, lifetimePercent)
			else
				this.scale.x = this.scale.y = pInfo.startSize
		this.scale = this.scale
		// Angle
		if (Util.isObject(pInfo.startAngle))
			this.angle = Util.toRadians(aUtils.decimalRand(pInfo.startAngle.randomBetween[0], pInfo.startAngle.randomBetween[1]))
		else
			this.angle = Util.toRadians(pInfo.startAngle)
		// Speed
		if (Util.isObject(pInfo.startSpeed))
			if (lifetimePercent && pInfo.endSpeed)
				pOwner.setSpeedOfParticle(this, lifetimePercent)
			else
				let speedRand = aUtils.decimalRand(pInfo.startSpeed.randomBetween[0], pInfo.startSpeed.randomBetween[1])
				// sSpeed
				this.info.sSpeed = speedRand
				this.info.speed = speedRand
		else
			if (lifetimePercent && pInfo.endSpeed)
				pOwner.setSpeedOfParticle(this, lifetimePercent)
			else
				this.info.speed = pInfo.startSpeed
		// SetTrajectory
		this.setTrajectory()
		// SetPos
		if (this.info.interfaceInfo.interface)
			let randomPaddingX = Math.rand(this.info.interfaceInfo.xPos - this.info.padding, this.info.interfaceInfo.xPos + this.info.padding)
			let randomPaddingY = Math.rand(this.info.interfaceInfo.yPos - this.info.padding, this.info.interfaceInfo.yPos + this.info.padding)
			// if (this._vy_parent)
			// 	this._vy_parent = null
			Client.addInterfaceElement(this, this.info.interfaceInfo.interface, this.id, randomPaddingX + this.info.trajectory.x, randomPaddingY + this.info.trajectory.y, [null, null, true])
		else
			// Only attemp to set the position if you have a valid `mapInfo` object
			if (this.info.mapInfo)
				// The owner of this (particle) is the particle generator, however we want the emitter of the particle generator itself so only use `useEmitterPos` in the condition that the particle gen has a emitter
				if (pOwner.settings.emitter)
					// if there is an emitter it needs to be set
					this.info.emitter = pOwner.settings.emitter
					if (this.info.mapInfo.useEmitterPos)
						// Only place it if the emitter has a valid mapName
						if (pOwner.settings.emitter.mapName)
							let randomPaddingX = Math.rand(pOwner.settings.emitter.xPos - this.info.padding, pOwner.settings.emitter.xPos + this.info.padding)
							let randomPaddingY = Math.rand(pOwner.settings.emitter.yPos - this.info.padding, pOwner.settings.emitter.yPos + this.info.padding)
							this.setPos((randomPaddingX + this.info.mapInfo.offset.x) + this.info.trajectory.x, (randomPaddingY + this.info.mapInfo.offset.y) + this.info.trajectory.y, pOwner.settings.emitter.mapName)
					
					if (this.info.mapInfo.useEmitterDirection)
						this.info.orientation = (this.info.mapInfo.useInverseDirection ? this.getInverseDir(pOwner.settings.emitter.dir) : pOwner.settings.emitter.dir)

				// There was no emitter of the particle gen so we use the `mapInfo` object that was given to us
				else
					let randomPaddingX = Math.rand(this.info.mapInfo.xPos - this.info.padding, this.info.mapInfo.xPos + this.info.padding)
					let randomPaddingY = Math.rand(this.info.mapInfo.yPos - this.info.padding, this.info.mapInfo.yPos + this.info.padding)
					this.setPos(randomPaddingX + this.info.trajectory.x, randomPaddingY + this.info.trajectory.y, this.info.mapInfo.mapName)
		// Light
		if (pOwner.usingLights)
			const color = pInfo.light.color ? pInfo.light.color : 0xFFFFFF
			const size = pInfo.light.size ? pInfo.light.size : 5
			const brightness = pInfo.light.brightness ? pInfo.light.brightness : 5
			const offset = pInfo.light?.offset
			const fadeDistance =  pInfo.light?.fadeDistance ? pInfo.light.fadeDistance : 0
			const cullDistance =  pInfo.light?.cullDistance ? pInfo.light.cullDistance : 0
			aLight.attachLight(this, { 'color': color, 'size': size, 'brightness': brightness, 'offset': offset, 'fadeDistance': fadeDistance, 'cullDistance': cullDistance, 'center': true, 'id': this.id })
		// this.text = 'Plane: ' + this.plane + ' Layer: ' + this.layer + ' Composite: ' + this.composite

	function setTrajectory()
		if (this.info.orientation)
			let angle = LIBRARY_getAngleFromDir(this.info.orientation)
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
					if (this.info.tempAngle.x === 0 && this.info.tempAngle.y === 0)
						this.info.tempAngle.x = Math.random() * (Math.prob(50) ? 1 : - 1)
						this.info.tempAngle.y = Math.random() * (Math.prob(50) ? 1 : - 1)
					this.info.trajectory.x = this.info.speed * this.info.tempAngle.x
					this.info.trajectory.y = this.info.speed * this.info.tempAngle.y

function LIBRARY_getAngleFromDir(pDir)
	switch (pDir)
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

function BezierEasing(pX1, pY1, pX2, pY2)
	return JS.BezierEasing(pX1, pY1, pX2, pY2)

#BEGIN JAVASCRIPT

function getRandomColorBetween(pColor1, pColor2) {
	let generator = new RandomColor(pColor1, pColor2);
	let color = generator.getColor();
	return color;
}

function getValues (pColor) {
	let values = false;
	let _regs = {
		"hex3": /^#([a-f\d])([a-f\d])([a-f\d])$/i,
		"hex6": /^#([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i,
		"rgb": /^rgb\s*\(\s*([\d\.]+%?)\s*\,\s*([\d\.]+%?)\s*\,\s*([\d\.]+%?)\s*\)$/
	};
	for (let prop in _regs) {
		if (_regs[prop].test(pColor)) {
			values = {};
			values.r = pColor.replace(_regs[prop], "$1");
			values.g = pColor.replace(_regs[prop], "$2");
			values.b = pColor.replace(_regs[prop], "$3");
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

function str_pad(pString, pPadLength, pPadString, pPadType) {
	let len = pPadLength - pString.length;
	if (len < 0) { return pString };
	let pad = new Array(len + 1).join(pPadString);
	if (pPadType === "STR_PAD_LEFT") { return pad + pString };
	return pString + pad;
}

function getRandom(pC1, pC2, pCent) {
	let color = pC1 + Math.floor((pC2 - pC1) * pCent);
	if (color < 0) color = 0;
	return str_pad(color.toString(16), 2, "0", "STR_PAD_LEFT");
}

function RandomColor(pColor1, pColor2) {
	let _obj1 = getValues(pColor1);
	let _obj2 = getValues(pColor2);

	this.getColor = function () {
		if (_obj1 && _obj2) {
			let random = Math.random();
			let r = getRandom(_obj1.r, _obj2.r, random);
			let g = getRandom(_obj1.g, _obj2.g, random);
			let b = getRandom(_obj1.b, _obj2.b, random);
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
