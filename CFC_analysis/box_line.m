function box_line(x,y,color,sh)
line([x-sh x-sh],[y-sh y+sh],'color',color,'linewidth',2)
line([x+sh x+sh],[y-sh y+sh],'color',color,'linewidth',2)
line([x-sh x+sh],[y-sh y-sh],'color',color,'linewidth',2)
line([x-sh x+sh],[y+sh y+sh],'color',color,'linewidth',2)
end