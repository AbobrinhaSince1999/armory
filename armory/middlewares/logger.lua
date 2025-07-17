return function(ctx, next)
	if ctx.type == "added" then
		print(string.format("[Logger] Component -> %s, added to: %s", ctx.component.name, ctx.instance.Name))
	elseif ctx.type == "removed" then
		print(string.format("[Logger] Component -> %s, removed from: %s", ctx.component.name, ctx.instance.Name))
	end

	next()
end