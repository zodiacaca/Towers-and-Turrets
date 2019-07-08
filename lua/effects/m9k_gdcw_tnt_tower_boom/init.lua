
function EFFECT:Init(data)

	self.Entity 		= data:GetEntity()		// Entity determines what is creating the dynamic light			//
	self.Pos 		= data:GetOrigin()		// Origin determines the global position of the effect			//
	self.Scale 		= data:GetScale()		// Scale determines how large the effect is			//
	self.DirVec 		= data:GetNormal()		// Normal determines the direction of impact for the effect			//
	self.PenVec 		= data:GetStart()		// PenVec determines the direction of the round for penetrations			//
	self.Particles 		= data:GetMagnitude()		// Particles determines how many puffs to make, primarily for "trails"	//
	self.Angle 		= self.DirVec:Angle()		// Angle is the angle of impact from Normal			//
	self.DebrizzlemyNizzle = math.random(10,20)		// Debrizzle my Nizzle is how many "trails" to make			//
	self.Size 		= 5*self.Scale		// Size is exclusively for the explosion "trails" size			//
	self.Emitter 	= ParticleEmitter( self.Pos )		// Emitter must be there so you don't get an error			//
	sound.Play( "ambient/explosions/explode_1.wav", self.Pos, 100, math.Rand(80,120)*GetConVarNumber("host_timescale") )

	self:Metal()

end

function EFFECT:Metal()

		for i=1,5 do
		local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Pos )
		if (Flash) then
		Flash:SetVelocity( self.DirVec*100 )
		Flash:SetDieTime( 0.15 )
		Flash:SetStartAlpha( 255 )
		Flash:SetEndAlpha( 0 )
		Flash:SetStartSize( self.Scale*200 )
		Flash:SetEndSize( 0 )
		Flash:SetRoll( math.Rand(180,480) )
		Flash:SetRollDelta( math.Rand(-1,1) )
		Flash:SetColor( 255,255,255 )
		Flash:SetAirResistance( 200 )
		end
		end

		for i=0, 30*self.Scale do
		local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Pos )
		if (Whisp) then
		Whisp:SetVelocity( VectorRand():GetNormalized()*math.random(200,1000*self.Scale) )
		Whisp:SetDieTime( math.Rand(4,10)*self.Scale/2  )
		Whisp:SetStartAlpha( math.Rand(50,70) )
		Whisp:SetEndAlpha( 0 )
		Whisp:SetStartSize( 70*self.Scale )
		Whisp:SetEndSize( 100*self.Scale )
		Whisp:SetRoll( math.Rand(150,360) )
		Whisp:SetRollDelta( math.Rand(-2,2) )
		Whisp:SetColor( 120,120,120 )
		Whisp:SetGravity( Vector(math.random(-40,40)*self.Scale, math.random(-40,40)*self.Scale,0) )
		Whisp:SetAirResistance( 300 )
		end
		end

 		for i=0, 30*self.Scale do
 		local Sparks = self.Emitter:Add( "effects/spark", self.Pos )
 		if (Sparks) then 
 		Sparks:SetVelocity( ((self.DirVec*0.75)+VectorRand())*math.Rand(200, 600)*self.Scale )
 		Sparks:SetDieTime( math.Rand(0.3,1) )
 		Sparks:SetStartAlpha( 255 )
 		Sparks:SetStartSize( math.Rand(7,15)*self.Scale )
 		Sparks:SetEndSize( 0 )
 		Sparks:SetRoll( math.Rand(0,360) )
 		Sparks:SetRollDelta( math.Rand(-5,5) )
		Sparks:SetGravity( Vector(0,0,-600) )
 		Sparks:SetAirResistance( 20 )
 		end
		end

 		for i=0, 10*self.Scale do 
 		local Sparks = self.Emitter:Add( "effects/yellowflare", self.Pos )
 		if (Sparks) then
 		Sparks:SetVelocity( VectorRand()*math.Rand(200, 600)*self.Scale )
 		Sparks:SetDieTime( math.Rand(1,1.7) )
 		Sparks:SetStartAlpha( 200 )
 		Sparks:SetStartSize( math.Rand(10,13)*self.Scale )
 		Sparks:SetEndSize( 0 )
 		Sparks:SetRoll( math.Rand(0,360) )
 		Sparks:SetRollDelta( math.Rand(-5,5) )
		Sparks:SetGravity( Vector(0,0,-60) )
 		Sparks:SetAirResistance( 100 )
 		end
		end
		
		sound.Play( "Bullet.Impact", self.Pos )

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end