del ".\Tempo.txt"

cd ..

for /l %%y in (0, 1,5) do (
	for /l %%x in (1, 1, 10) do (
	   start /w love.lnk "D:\Filipe\Desktop\Faculdade\love threads\BFS + AStar" %%y "D:\\Filipe\\Desktop\\Faculdade\\love threads\\BFS + AStar"
	)
)

for /l %%x in (1, 1, 10) do (
	start /w love.lnk "D:\Filipe\Desktop\Faculdade\love threads\BFS + AStar" 10 "D:\\Filipe\\Desktop\\Faculdade\\love threads\\BFS + AStar"
)

for /l %%x in (1, 1, 10) do (
	start /w love.lnk "D:\Filipe\Desktop\Faculdade\love threads\BFS + AStar" 15 "D:\\Filipe\\Desktop\\Faculdade\\love threads\\BFS + AStar"
)

for /l %%x in (1, 1, 10) do (
	start /w love.lnk "D:\Filipe\Desktop\Faculdade\love threads\BFS + AStar" 1000 "D:\\Filipe\\Desktop\\Faculdade\\love threads\\BFS + AStar"
)