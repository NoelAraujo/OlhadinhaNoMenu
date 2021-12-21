using Images, ImageBinarization
using OCReract, ReadableRegex
using Plots

function pegar_preços(img_path)
    img = Images.load(img_path)
    img_gray = Gray.(img)

    alg = AdaptiveThreshold(window_size = 150)
    binary_img = binarize(img_gray, alg)
    

    res_text = run_tesseract(binary_img, psm=11, oem=1, lang="por");
    reg = maybe(["-", "+"]) *
                maybe(zero_or_more(DIGIT) * ".") *
                one_or_more(DIGIT)
    preços_regex = collect(eachmatch(reg, res_text))

    preços = [parse(Float64, String(preço.match)) for preço in preços_regex]
    return preços
end


nome_pasta = "toka_do_kastor"

todos_preços = Float64[]
for foto in readdir(pwd()*"/"*nome_pasta)
    img_path = pwd()*"/"*nome_pasta*"/"*foto
    append!(todos_preços, pegar_preços(img_path))

    println(img_path)
end


#= 

Elimina os pontos fora da curva com estatistica
Essa opção não é estável enquanto o OCR não for estável

using Statistics
x = sort(todos_preços)
q1 = quantile(x, 0.35)
q3 = quantile(x, 0.887)
preços_limpos = x[findall((x .≥ q1).*(x .≤ q3))]

=#

## Eliminar Valores Errados (por falha do OCR) e Exibe o Histograma
valor_min = 10
valor_max = 60
preços_limpos = todos_preços[findall((todos_preços .≥ valor_min).*(todos_preços .≤ valor_max))]


histogram(preços_limpos, xlabel="Preços", ylabel="qtd de itens", label=nome_pasta)