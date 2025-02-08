ChaosModifierNormalVisualization = ChaosModifier.class("ChaosModifierNormalVisualization")
ChaosModifierNormalVisualization.register_name = "ChaosModifierScreenEffect"
ChaosModifierNormalVisualization.duration = 40

function ChaosModifierNormalVisualization:start()
	CoreDebug.change_visualization("normal_visualization")
end

function ChaosModifierNormalVisualization:stop()
	CoreDebug.change_visualization("deferred_lighting")
end

return ChaosModifierNormalVisualization
