import { createRef } from "react";
import { Grid, GridProps } from "@react-three/drei";

import { useInput } from "../input/useInput";
import { getState, useStore } from "../store";
import { buildFacility } from "../systems/constructionSystem";
import { Directions } from "@/lib/utils";

const gridSize = 1000;

function GridRenderer() {
  const gridConfig = {
    cellSize: 1,
    cellThickness: 0.9,
    cellColor: "#76EAE4",
    sectionSize: 5,
    sectionThickness: 1,
    sectionColor: "#76EAE4",
    fadeDistance: 40,
    fadeStrength: 2,
    followCamera: true,
    infiniteGrid: true,
    depthTest: false,
  } as GridProps;
  return <Grid position={[0, 0, 50]} args={[30.5, 30.5]} {...gridConfig} />;
}

function Ground() {
  const {
    input: { building },
  } = useStore();
  const gridRef = createRef<THREE.Mesh>();

  const { onMouseMove } = useInput((event) => {
    const {
      input: { cursor },
    } = getState();
    cursor.setCursor({
      position: event.position,
      direction: Directions.DOWN(),
    });
  }, gridRef);

  const { onMouseDown, onMouseClick } = useInput((event) => {
    buildFacility(event.position);
  }, gridRef);

  return (
    <>
      {building && <GridRenderer />}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        receiveShadow
        userData={{ type: "grid" }}
        ref={gridRef}
        onPointerDown={onMouseDown}
        onClick={onMouseClick}
        onPointerMove={onMouseMove}
        onPointerEnter={onMouseMove}
      >
        <planeGeometry args={[gridSize, gridSize]} />
        <meshToonMaterial attach="material" visible={false} />
      </mesh>
    </>
  );
}

export default Ground;
