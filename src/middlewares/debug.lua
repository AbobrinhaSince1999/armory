return function(ctx, next)
	if ctx.type == "attach" then
		print(string.format("[Debug] Component -> %s, attached to: %s", ctx.component.name, ctx.instance.Name))
	elseif ctx.type == "detach" then
		print(string.format("[Debug] Component -> %s, detached from: %s", ctx.component.name, ctx.instance.Name))
	end

	next()
end