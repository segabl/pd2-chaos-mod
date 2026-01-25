ChaosModifierAlbedoVisualization = ChaosModifier.class("ChaosModifierAlbedoVisualization")
ChaosModifierAlbedoVisualization.tags = { "ScreenEffect", "NoLights" }
ChaosModifierAlbedoVisualization.conflict_tags = { "ScreenEffect" }
ChaosModifierAlbedoVisualization.duration = 60

function ChaosModifierAlbedoVisualization:start()
	CoreDebug.change_visualization("albedo_visualization")
end

function ChaosModifierAlbedoVisualization:stop()
	CoreDebug.change_visualization("deferred_lighting")
end

return ChaosModifierAlbedoVisualization
