
matproxy.Add(
{
	name = "TNTMixmap",

	init	= function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind	=	function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end

		local col = Vector( 1, 1, 1 )

		local mul = ( 1 + math.sin( CurTime() * 8 ) )^2 * 63

		mat:SetVector( self.ResultTo, col * mul + Vector( 3, 3, 3 ) )

	end
})