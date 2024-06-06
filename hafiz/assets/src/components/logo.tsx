export interface LogoProps {
  width: string
  height: string
  className?: string
}

export const Logo = (props: LogoProps) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 -0.5 32 32"
      fill="none"
      shapeRendering="crispEdges"
      {...props}
    >
      <title>little red book</title>
      <path
        stroke="#640529"
        d="M5 1h2M11 1h14M5 2h2M11 2h14M3 3h2M3 4h2M3 5h2M7 5h2M27 5h2M3 6h2M7 6h2M27 6h2M3 7h2M7 7h2M27 7h2M3 8h2M7 8h2M27 8h2M3 9h2M7 9h2M27 9h2M3 10h2M7 10h2M27 10h2M3 11h2M7 11h2M27 11h2M3 12h2M7 12h2M27 12h2M3 13h2M7 13h2M27 13h2M3 14h2M7 14h2M27 14h2M3 15h2M7 15h2M27 15h2M3 16h2M7 16h2M27 16h2M3 17h2M7 17h2M27 17h2M3 18h2M7 18h2M27 18h2M3 19h2M27 19h2M3 20h2M27 20h2M3 21h4M11 21h16M3 22h4M11 22h16M3 23h2M27 23h2M3 24h2M27 24h2M3 25h2M27 25h2M3 26h2M27 26h2M3 27h2M27 27h2M3 28h2M27 28h2M5 29h24M5 30h24"
      />
      <path
        stroke="#d27627"
        d="M7 1h2M27 1h2M7 2h2M27 2h2M15 8h2M15 9h2M13 12h2M17 12h2M13 13h2M17 13h2M7 21h2M27 21h2M7 22h2M27 22h2"
      />
      <path
        stroke="#dca251"
        d="M9 1h2M25 1h2M9 2h2M25 2h2M7 3h2M27 3h2M7 4h2M27 4h2M13 8h2M17 8h6M13 9h2M17 9h6M15 12h2M19 12h4M15 13h2M19 13h4M7 19h2M7 20h2M9 21h2M9 22h2"
      />
      <path
        stroke="#a81b41"
        d="M5 3h2M9 3h18M5 4h2M9 4h18M5 5h2M9 5h18M5 6h2M9 6h18M5 7h2M9 7h18M5 8h2M9 8h4M23 8h4M5 9h2M9 9h4M23 9h4M5 10h2M9 10h18M5 11h2M9 11h18M5 12h2M9 12h4M23 12h4M5 13h2M9 13h4M23 13h4M5 14h2M9 14h18M5 15h2M9 15h18M5 16h2M9 16h18M5 17h2M9 17h18M5 18h2M9 18h18M5 19h2M9 19h18M5 20h2M9 20h18"
      />
      <path stroke="#fecfbb" d="M5 23h4M15 23h12M5 24h4M15 24h12M5 27h22M5 28h22" />
      <path stroke="#a81b3f" d="M9 23h6M9 24h6" />
      <path stroke="#f5efe7" d="M5 25h4M11 25h2M15 25h12M5 26h4M11 26h2M15 26h12" />
      <path stroke="#ee3d3e" d="M9 25h2M13 25h2M9 26h2M13 26h2" />
    </svg>
  )
}
