
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

	self:Dust()

end
 
 function EFFECT:Dust()

		for i=1,200*self.Scale do
		local Dust = self.Emitter:Add( "particle/particle_composite", self.Pos )
		if (Dust) then
		Dust:SetVelocity( self.DirVec*math.Rand(100,400)*self.Scale + ((VectorRand():GetNormalized()*300)*self.Scale) )
		Dust:SetDieTime( math.Rand(2,3) )
		Dust:SetStartAlpha( 230 )
		Dust:SetEndAlpha( 0 )
		Dust:SetStartSize( (50*self.Scale) )
		Dust:SetEndSize( (100*self.Scale) )
		Dust:SetRoll( math.Rand(150,360) )
		Dust:SetRollDelta( math.Rand(-1,1) )
		Dust:SetColor( 80,80,80 )
		Dust:SetGravity( Vector(0,0,math.Rand(-100,-400)) )
		Dust:SetAirResistance( 150 )
		end
		end

		for i=1,15*self.Scale do
		local Dust = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Pos )
		if (Dust) then
		Dust:SetVelocity( self.DirVec*math.Rand(100,400)*self.Scale + ((VectorRand():GetNormalized()*400)*self.Scale) )
		Dust:SetDieTime( math.Rand(1,5)*self.Scale )
		Dust:SetStartAlpha( 50 )
		Dust:SetEndAlpha( 0 )
		Dust:SetStartSize( (80*self.Scale) )
		Dust:SetEndSize( (100*self.Scale) )
		Dust:SetRoll( math.Rand(150,360) )
		Dust:SetRollDelta( math.Rand(-1,1) )
		Dust:SetColor( 90,85,75 )
		Dust:SetGravity( Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(10,100)) )
		Dust:SetAirResistance( 250 )
		end
		end

		for i=1,25*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Pos )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec*math.random(0,700)*self.Scale + VectorRand():GetNormalized()*math.random(0,700)*self.Scale )
		Debris:SetDieTime( math.random(1,2)*self.Scale )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(5,10)*self.Scale )
		Debris:SetRoll( math.Rand(0,360) )
		Debris:SetRollDelta( math.Rand(-5,5) )
		Debris:SetColor( 60,60,60 )	
		Debris:SetGravity( Vector(0,0,-600) )
		Debris:SetAirResistance( 40 )
		end
		end

		local Angle = self.DirVec:Angle()
		for i=1,self.DebrizzlemyNizzle do		// This part makes the trailers
		Angle:RotateAroundAxis(Angle:Forward(), (360/self.DebrizzlemyNizzle))
		local DustRing = Angle:Up()
		local RanVec = self.DirVec*math.Rand(0.5,3) + (DustRing*math.Rand(3,7))

			for k=3,self.Particles do
			local Rcolor = math.random(-20,20)
			local particle1 = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Pos )	
			particle1:SetVelocity( (VectorRand():GetNormalized()*math.Rand(1,2)*self.Size) + (RanVec*self.Size*k*3.5) )
			particle1:SetDieTime( math.Rand(0.5,4)*self.Scale )
			particle1:SetStartAlpha( math.Rand(90,100) )
			particle1:SetEndAlpha( 0 )
			particle1:SetStartSize( (5*self.Size)-((k/self.Particles)*self.Size*3) )
			particle1:SetEndSize( (20*self.Size)-((k/self.Particles)*self.Size) )
			particle1:SetRoll( math.random(-500,500)/100 )
			particle1:SetRollDelta( math.random(-0.5,0.5) )
			particle1:SetColor( 110+Rcolor,107+Rcolor,100+Rcolor )
			particle1:SetGravity( (VectorRand():GetNormalized()*math.Rand(5,10)*self.Size) + Vector(0,0,-50) )
			particle1:SetAirResistance( 400 )
			end

		end

 end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end