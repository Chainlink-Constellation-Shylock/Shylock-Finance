import { useRef, useEffect } from 'react';
import * as d3 from 'd3';

interface BulletChartProps {
  isDaoScore?: boolean;
  score: number;
  targetValue?: number;
}

export const BulletChart: React.FC<BulletChartProps> = ({ isDaoScore, score, targetValue }) => {
  const d3Container = useRef(null);
  const maxValue = 100;

  useEffect(() => {
    if (d3Container.current) {
      const svg = d3.select(d3Container.current);

      svg.selectAll("*").remove();

      const width = 400;
      const height = 80;
      const margin = { top: 10, right: 20, bottom: 20, left: 20 };

      const xScale = d3.scaleLinear().range([0, width]).domain([0, maxValue]);

      svg.append('rect')
        .attr('x', 0)
        .attr('y', 10)
        .attr('width', xScale(score))
        .attr('height', 30)
        .style('fill', '#f47560');
      
      if (isDaoScore && targetValue) {
        svg.append('line')
          .attr('x1', xScale(targetValue))
          .attr('x2', xScale(targetValue))
          .attr('y1', 10)
          .attr('y2', 40)
          .style('stroke', 'black')
          .style('stroke-width', '2');
      }
      

      svg.append("g")
        .attr("transform", `translate(0,${margin.top + 30})`)
        .call(d3.axisBottom(xScale));

      // Add legend
      const legend = svg.append('g')
        .attr('transform', `translate(0, ${height - margin.bottom})`);

      legend.append('rect')
        .attr('x', 0)
        .attr('width', 20)
        .attr('height', 25)
        .style('fill', '#f47560');

      legend.append('text')
        .attr('x', 30)
        .attr('y', 20)
        .text('DAO Score');
      if (isDaoScore) {
        legend.append('line')
          .attr('x1', 170)
          .attr('x2', 190)
          .attr('y1', 15)
          .attr('y2', 15)
          .style('stroke', 'black')
          .style('stroke-width', '2');

        legend.append('text')
          .attr('x', 200)
          .attr('y', 20)
          .text('Target');
      }
    }
  }, [score]);

  return (
    <svg
      className="d3-component"
      width={400}
      height={100}
      ref={d3Container}
    />
  );
};
