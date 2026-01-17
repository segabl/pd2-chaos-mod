ChaosModifierAlbedoVisualization = ChaosModifier.class("ChaosModifierAlbedoVisualization")
ChaosModifierAlbedoVisualization.conflict_tags = { "ScreenEffect", "NoLights" }
ChaosModifierAlbedoVisualization.duration = 60

function ChaosModifierAlbedoVisualization:start()
	CoreDebug.change_visualization("albedo_visualization")
end

function ChaosModifierAlbedoVisualization:stop()
	CoreDebug.change_visualization("deferred_lighting")
end

return ChaosModifierAlbedoVisualization
