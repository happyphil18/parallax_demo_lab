# Parallax2D Demo Lab

這個 Godot 4.5 專案對應課堂五 `2D Parallax` 文件的核心概念，聚焦四個屬性：

- `scroll_scale`
- `repeat_size`
- `scroll_offset`
- `repeat_times`

## 操作

- `A / D` 或左右鍵：水平移動 `Camera2D`
- `W / S` 或上下鍵：調整 `Camera2D.zoom`
- `1`：切換顯示各層 `scroll_scale`
- `2`：切換 `repeat_size` guide
- `3`：切換 `scroll_offset`
- `4`：切換 `repeat_times`
- `R`：重設
- `Tab`：切換 HUD 詳細模式

## 教學觀察重點

- 背景層和前景層相對於相機移動的速度不同
- `repeat_size` guide 會顯示每層的水平循環區間
- `scroll_offset` 會改變圖層起始位置
- 拉遠鏡頭後，`repeat_times` 較低時更容易露出循環覆蓋不足的問題
