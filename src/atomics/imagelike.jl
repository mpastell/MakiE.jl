

function heatmap2glvisualize(attributes)
    result = Dict{Symbol, Any}()
    result[:stroke_width] = to_signal(attributes[:linewidth])
    result[:levels] = to_signal(attributes[:levels])
    result[:color_norm] = to_signal(attributes[:colornorm])
    result[:color_map] = to_signal(attributes[:colormap])

    heatmap = to_signal(lift_node(attributes[:heatmap]) do z
        [GLVisualize.Intensity{Float32}(z[j, i]) for i = 1:size(z, 2), j = 1:size(z, 1)]
    end)
    tex = GLAbstraction.Texture(value(heatmap), minfilter = :nearest)
    foreach(heatmap) do x
        update!(tex, x)
    end
    result, tex
end

function heatmap(b::makie, x, y, z, attributes)
    attributes[:x] = x
    attributes[:y] = y
    attributes[:heatmap] = z
    scene = get_global_scene()
    attributes = heatmap_defaults(b, scene, attributes)
    gl_data, tex = heatmap2glvisualize(attributes)
    viz = visualize(tex, Style(:default), gl_data).children[]
    insert_scene!(scene, :heatmap, viz, attributes)
end


function image2glvisualize(attributes)
    result = Dict{Symbol, Any}()
    result[:primitive] = to_signal(lift_node(getindex.(attributes, (:x, :y, :spatialorder))...) do x, y, so
        if so != "xy"
            y, x = x, y
        end
        xmin, ymin = minimum(x), minimum(y)
        xmax, ymax = maximum(x), maximum(y)
        SimpleRectangle{Float32}(xmin, ymin, xmax - xmin, ymax - ymin)
    end)
    result[:spatialorder] = to_value(attributes[:spatialorder])
    result
end

function image(b::makie, x, y, img, attributes::Dict)
    scene = get_global_scene()
    attributes[:x] = x
    attributes[:y] = y
    attributes[:image] = img
    attributes = image_defaults(b, scene, attributes)
    gl_data = image2glvisualize(attributes)
    viz = visualize(to_signal(attributes[:image]), Style(:default), gl_data).children[]
    insert_scene!(scene, :image, viz, attributes)
end

function volume2glvisualize(attributes)
    result = Dict{Symbol, Any}()
    if haskey(attributes, :colornorm)
        result[:color_norm] = to_signal(attributes[:colornorm])
        result[:color_map] = to_signal(attributes[:colormap])
    else
        result[:color_map] = nothing
        result[:color_norm] = nothing
        result[:color] = to_signal(attributes[:color])
    end

    result[:algorithm] = to_signal(attributes[:algorithm])
    result[:isovalue] = to_signal(attributes[:isovalue])
    result[:isorange] = to_signal(attributes[:isorange])
    result[:absorption] = to_signal(attributes[:absorption])

    result
end

function volume(b::makie, values, attributes)
    attributes[:volume] = values
    scene = get_global_scene()
    attributes = volume_defaults(b, scene, attributes)
    gl_data = volume2glvisualize(attributes)
    viz = visualize(to_signal(attributes[:volume]), Style(:default), gl_data).children[]
    insert_scene!(scene, :volume, viz, attributes)
end
