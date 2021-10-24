using ArgParse
using Images


const ASCII_PALETTE = "MWNXK0Okxdolc:;,'...   "
const CHAR_HEIGHT = 99
const CHAR_WIDTH = 56


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "path_to_img"
        	help = "Path to the image to be converted to ASCII."
        	arg_type = String
        	required = true

		"--width", "-w"
			help = "Set a new width for the (rescaled) image."
			arg_type = Int64
			required = false
    end

    return parse_args(ARGS, s)
end


function load_image(path_to_image::String)
    img = load(path_to_image)
end


function rescale_img(image::Array,
					 char_height::Int64,
					 char_width::Int64,
					 new_width::Int64)
	new_size = (new_width, trunc(Int64, new_width*char_height/char_width))
	img_rescaled = imresize(image, new_size)
end


function grayscale_img(image::Array)
	Gray.(image)
end


function html_base_string(img::Array)
	img_width = size(img)[2]
	html_header =
		"<!DOCTYPE html>\n
		<html>\n
		<head>\n
		<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">\n
		<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>\n
		<link href=\"https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@300&display=swap\" rel=\"stylesheet\">\n
		<style>\n
		\n
		html, body {\n
		}\n
		.txt {\n
			font-family: 'Roboto Mono', monospace;\n
			font-size: 10pt;\n
		}\n
		\n
		</style>\n
		</head>\n
		<body>\n
		<div class=\"txt\">\n
		\n"
end


function img_to_ascii(img::Array, ascii_palette::String)
	rgb_img = floor.(Int64, channelview(img) * 255)
	gray_img = grayscale_img(img)
	normalized_img = (channelview(gray_img) * (length(ascii_palette) - 1)) .+ 1
	normalized_img = round.(Int64, normalized_img)
	ascii_img = html_base_string(img)
	for i in 1:size(normalized_img)[1]
		for j in 1:size(normalized_img)[2]
			pixel = string(rgb_img[1, i, j],
			 			   ",",
						   rgb_img[2, i, j],
						   ",",
						   rgb_img[3, i, j])
			color = "rgb($pixel)"
			ascii_img *= "<span style=\"color: " *
						 color *
						 "\">" *
						 ascii_palette[normalized_img[i,j]] *
						 "</span>"
		end
		ascii_img *= "<br>\n" # HTML line break
	end
	# Now close body and html elements
	ascii_img *=
		"</div>\n
		</body>\n
		</html>"
	return ascii_img
end


function save_to_html(path_to_html::String, ascii_img::String)
	open(path_to_html, "w") do f
		write(f, ascii_img)
	end
end


function main()
	parsed_args = parse_commandline()
	path_to_img = parsed_args["path_to_img"]
    img = load_image(path_to_img)
	if parsed_args["width"] != nothing
		img = rescale_img(img, CHAR_HEIGHT, CHAR_WIDTH, parsed_args["width"])
	else
		img = rescale_img(img, CHAR_HEIGHT, CHAR_WIDTH, size(img)[2])
	end
	ascii_img = img_to_ascii(img, ASCII_PALETTE)
	idx = findlast(".", path_to_img)[1] # index of the last dot (.) character
	path_to_html = path_to_img[1:idx] * "html"
	save_to_html(path_to_html, ascii_img)
	println("ASCII image saved at $path_to_html")
end


main()
