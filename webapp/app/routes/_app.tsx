import { Link, NavLink, Outlet } from "@remix-run/react"
import { ArchiveIcon, GaugeIcon, ImageIcon, SearchIcon, SettingsIcon, UserIcon } from "lucide-react"
import { css } from "styled-system/css"
import { Center, Flex, styled } from "styled-system/jsx"
import { flex, vstack } from "styled-system/patterns"
import { Badge } from "~/app/components/ui/badge"
import { Button } from "~/app/components/ui/button"

const NAVIGATIONS = [
  { name: "Dashboard", icon: GaugeIcon, route: "/dashboard" },
  { name: "Archive", icon: ArchiveIcon, route: "/archive" },
  { name: "Gallery", icon: ImageIcon, route: "/gallery" },
  { name: "Account", icon: UserIcon, route: "/account" },
  { name: "Settings", icon: SettingsIcon, route: "/settings" }
]

export default function AppLayout() {
  return (
    <>
      <Navbar />
      <Main />
    </>
  )
}

const Navbar = () => {
  return (
    <Flex
      direction="column"
      pt="4"
      px="4"
      w="72"
      position="fixed"
      top="0"
      bottom="0"
      left="0"
      borderRightWidth="1px"
    >
      <BrandSection />
      <NavSection />
    </Flex>
  )
}

const BrandSection = () => {
  return (
    <Flex mx="-4" px="4" pb="4" borderBottomWidth="1px" justify="space-between" align="center">
      <Link to="/">
        <Logo width="172" height="32" />
      </Link>
      <Badge>dev0.1</Badge>
    </Flex>
  )
}

const NavSection = () => {
  return (
    <Flex mx="-4" px="4" py="4" direction="column" gap="4" borderBottomWidth="1px">
      <Button variant="outline" justifyContent="space-between">
        <styled.span display="inline-flex">
          <SearchIcon className={css({ mr: "2" })} /> Search
        </styled.span>
        <Badge>CTRL + K</Badge>
      </Button>
      <styled.nav>
        <styled.ul className={vstack({ gap: "1" })}>
          {NAVIGATIONS.map(({ name, icon: Icon, route }) => (
            <styled.li key={name} w="full">
              <NavLink
                to={route}
                className={flex({
                  p: "2",
                  align: "center",
                  rounded: "lg",
                  _hover: { bg: "accent.2" },
                  _focus: { bg: "accent.2" },
                  _focusVisible: {
                    outlineColor: "accent.emphasized",
                    outlineStyle: "solid",
                    outlineWidth: "2px",
                    outlineOffset: "2px"
                  },
                  _currentPage: {
                    bg: "accent.emphasized",
                    _hover: {
                      bg: "accent.emphasized"
                    },
                    _focus: {
                      bg: "accent.emphasized"
                    },
                    "& [data-nav-label]": { color: "white" }
                  }
                })}
              >
                <Center mr="4" w="8" h="8" bg="accent.4" rounded="md">
                  <Icon className={css({ width: "5", height: "5", color: "accent.text" })} />
                </Center>
                <styled.span data-nav-label fontSize="sm" fontWeight="medium">
                  {name}
                </styled.span>
              </NavLink>
            </styled.li>
          ))}
        </styled.ul>
      </styled.nav>
    </Flex>
  )
}

const Main = () => {
  return (
    <styled.main ml="72">
      <Outlet />
    </styled.main>
  )
}

type LogoProps = {
  width: string
  height: string
}

const Logo = ({ width, height }: LogoProps) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={width}
      height={height}
      viewBox="0 0 235 35"
      fill="none"
    >
      <path
        d="M39.5 28V10.5H43V24.5H50V28H39.5ZM51.96 28V10.5H55.46V28H51.96ZM60.92 28V14H57.42V10.5H67.92V14H64.42V28H60.92ZM73.38 28V14H69.88V10.5H80.38V14H76.88V28H73.38ZM82.34 28V10.5H85.84V24.5H92.84V28H82.34ZM94.8 28V10.5H105.3V14H98.3V17.5H105.3V21H98.3V24.5H105.3V28H94.8ZM116.22 28V10.5H126.72V14H130.22V17.5H126.72V24.5H130.22V28H126.72V24.5H123.22V21H119.72V28H116.22ZM119.72 14V17.5H126.58V14H119.72ZM132.18 28V10.5H142.68V14H135.68V17.5H142.68V21H135.68V24.5H142.68V28H132.18ZM155.14 28H144.64V10.5H155.14V14H158.64V24.5H155.14V28ZM148.14 14V24.5H155V14H148.14ZM169.56 28V10.5H180.06V14H183.56V24.5H180.06V28H169.56ZM173.06 14V17.5H179.92V14H173.06ZM173.06 21V24.5H179.92V21H173.06ZM185.52 24.5V14H189.02V10.5H196.02V14H199.52V24.5H196.02V28H189.02V24.5H185.52ZM189.02 14.14V24.36H196.02V14.14H189.02ZM201.48 24.5V14H204.98V10.5H211.98V14H215.48V24.5H211.98V28H204.98V24.5H201.48ZM204.98 14.14V24.36H211.98V14.14H204.98ZM220.94 28H217.44V10.5H220.94V17.5H224.44V21H227.94V24.5H231.44V28H227.94V24.5H224.44V21H220.94V28ZM227.94 17.5H224.44V14H227.94V17.5ZM231.44 14H227.94V10.5H231.44V14Z"
        fill="#A81B41"
      />
      <path
        d="M5 4.5H7H5ZM11 4.5H25H11ZM5 5.5H7H5ZM11 5.5H25H11ZM3 6.5H5H3ZM3 7.5H5H3ZM3 8.5H5H3ZM7 8.5H9H7ZM27 8.5H29H27ZM3 9.5H5H3ZM7 9.5H9H7ZM27 9.5H29H27ZM3 10.5H5H3ZM7 10.5H9H7ZM27 10.5H29H27ZM3 11.5H5H3ZM7 11.5H9H7ZM27 11.5H29H27ZM3 12.5H5H3ZM7 12.5H9H7ZM27 12.5H29H27ZM3 13.5H5H3ZM7 13.5H9H7ZM27 13.5H29H27ZM3 14.5H5H3ZM7 14.5H9H7ZM27 14.5H29H27ZM3 15.5H5H3ZM7 15.5H9H7ZM27 15.5H29H27ZM3 16.5H5H3ZM7 16.5H9H7ZM27 16.5H29H27ZM3 17.5H5H3ZM7 17.5H9H7ZM27 17.5H29H27ZM3 18.5H5H3ZM7 18.5H9H7ZM27 18.5H29H27ZM3 19.5H5H3ZM7 19.5H9H7ZM27 19.5H29H27ZM3 20.5H5H3ZM7 20.5H9H7ZM27 20.5H29H27ZM3 21.5H5H3ZM7 21.5H9H7ZM27 21.5H29H27ZM3 22.5H5H3ZM27 22.5H29H27ZM3 23.5H5H3ZM27 23.5H29H27ZM3 24.5H7H3ZM11 24.5H27H11ZM3 25.5H7H3ZM11 25.5H27H11ZM3 26.5H5H3ZM27 26.5H29H27ZM3 27.5H5H3ZM27 27.5H29H27ZM3 28.5H5H3ZM27 28.5H29H27ZM3 29.5H5H3ZM27 29.5H29H27ZM3 30.5H5H3ZM27 30.5H29H27ZM3 31.5H5H3ZM27 31.5H29H27ZM5 32.5H29H5ZM5 33.5H29H5Z"
        fill="black"
      />
      <path
        d="M5 4.5H7M11 4.5H25M5 5.5H7M11 5.5H25M3 6.5H5M3 7.5H5M3 8.5H5M7 8.5H9M27 8.5H29M3 9.5H5M7 9.5H9M27 9.5H29M3 10.5H5M7 10.5H9M27 10.5H29M3 11.5H5M7 11.5H9M27 11.5H29M3 12.5H5M7 12.5H9M27 12.5H29M3 13.5H5M7 13.5H9M27 13.5H29M3 14.5H5M7 14.5H9M27 14.5H29M3 15.5H5M7 15.5H9M27 15.5H29M3 16.5H5M7 16.5H9M27 16.5H29M3 17.5H5M7 17.5H9M27 17.5H29M3 18.5H5M7 18.5H9M27 18.5H29M3 19.5H5M7 19.5H9M27 19.5H29M3 20.5H5M7 20.5H9M27 20.5H29M3 21.5H5M7 21.5H9M27 21.5H29M3 22.5H5M27 22.5H29M3 23.5H5M27 23.5H29M3 24.5H7M11 24.5H27M3 25.5H7M11 25.5H27M3 26.5H5M27 26.5H29M3 27.5H5M27 27.5H29M3 28.5H5M27 28.5H29M3 29.5H5M27 29.5H29M3 30.5H5M27 30.5H29M3 31.5H5M27 31.5H29M5 32.5H29M5 33.5H29"
        stroke="#640529"
      />
      <path
        d="M7 4.5H9H7ZM27 4.5H29H27ZM7 5.5H9H7ZM27 5.5H29H27ZM15 11.5H17H15ZM15 12.5H17H15ZM13 15.5H15H13ZM17 15.5H19H17ZM13 16.5H15H13ZM17 16.5H19H17ZM7 24.5H9H7ZM27 24.5H29H27ZM7 25.5H9H7ZM27 25.5H29H27Z"
        fill="black"
      />
      <path
        d="M7 4.5H9M27 4.5H29M7 5.5H9M27 5.5H29M15 11.5H17M15 12.5H17M13 15.5H15M17 15.5H19M13 16.5H15M17 16.5H19M7 24.5H9M27 24.5H29M7 25.5H9M27 25.5H29"
        stroke="#D27627"
      />
      <path
        d="M9 4.5H11H9ZM25 4.5H27H25ZM9 5.5H11H9ZM25 5.5H27H25ZM7 6.5H9H7ZM27 6.5H29H27ZM7 7.5H9H7ZM27 7.5H29H27ZM13 11.5H15H13ZM17 11.5H23H17ZM13 12.5H15H13ZM17 12.5H23H17ZM15 15.5H17H15ZM19 15.5H23H19ZM15 16.5H17H15ZM19 16.5H23H19ZM7 22.5H9H7ZM7 23.5H9H7ZM9 24.5H11H9ZM9 25.5H11H9Z"
        fill="black"
      />
      <path
        d="M9 4.5H11M25 4.5H27M9 5.5H11M25 5.5H27M7 6.5H9M27 6.5H29M7 7.5H9M27 7.5H29M13 11.5H15M17 11.5H23M13 12.5H15M17 12.5H23M15 15.5H17M19 15.5H23M15 16.5H17M19 16.5H23M7 22.5H9M7 23.5H9M9 24.5H11M9 25.5H11"
        stroke="#DCA251"
      />
      <path
        d="M5 6.5H7H5ZM9 6.5H27H9ZM5 7.5H7H5ZM9 7.5H27H9ZM5 8.5H7H5ZM9 8.5H27H9ZM5 9.5H7H5ZM9 9.5H27H9ZM5 10.5H7H5ZM9 10.5H27H9ZM5 11.5H7H5ZM9 11.5H13H9ZM23 11.5H27H23ZM5 12.5H7H5ZM9 12.5H13H9ZM23 12.5H27H23ZM5 13.5H7H5ZM9 13.5H27H9ZM5 14.5H7H5ZM9 14.5H27H9ZM5 15.5H7H5ZM9 15.5H13H9ZM23 15.5H27H23ZM5 16.5H7H5ZM9 16.5H13H9ZM23 16.5H27H23ZM5 17.5H7H5ZM9 17.5H27H9ZM5 18.5H7H5ZM9 18.5H27H9ZM5 19.5H7H5ZM9 19.5H27H9ZM5 20.5H7H5ZM9 20.5H27H9ZM5 21.5H7H5ZM9 21.5H27H9ZM5 22.5H7H5ZM9 22.5H27H9ZM5 23.5H7H5ZM9 23.5H27H9Z"
        fill="black"
      />
      <path
        d="M5 6.5H7M9 6.5H27M5 7.5H7M9 7.5H27M5 8.5H7M9 8.5H27M5 9.5H7M9 9.5H27M5 10.5H7M9 10.5H27M5 11.5H7M9 11.5H13M23 11.5H27M5 12.5H7M9 12.5H13M23 12.5H27M5 13.5H7M9 13.5H27M5 14.5H7M9 14.5H27M5 15.5H7M9 15.5H13M23 15.5H27M5 16.5H7M9 16.5H13M23 16.5H27M5 17.5H7M9 17.5H27M5 18.5H7M9 18.5H27M5 19.5H7M9 19.5H27M5 20.5H7M9 20.5H27M5 21.5H7M9 21.5H27M5 22.5H7M9 22.5H27M5 23.5H7M9 23.5H27"
        stroke="#A81B41"
      />
      <path
        d="M5 26.5H9H5ZM15 26.5H27H15ZM5 27.5H9H5ZM15 27.5H27H15ZM5 30.5H27H5ZM5 31.5H27H5Z"
        fill="black"
      />
      <path d="M5 26.5H9M15 26.5H27M5 27.5H9M15 27.5H27M5 30.5H27M5 31.5H27" stroke="#FECFBB" />
      <path d="M9 26.5H15H9ZM9 27.5H15H9Z" fill="black" />
      <path d="M9 26.5H15M9 27.5H15" stroke="#A81B3F" />
      <path
        d="M5 28.5H9H5ZM11 28.5H13H11ZM15 28.5H27H15ZM5 29.5H9H5ZM11 29.5H13H11ZM15 29.5H27H15Z"
        fill="black"
      />
      <path d="M5 28.5H9M11 28.5H13M15 28.5H27M5 29.5H9M11 29.5H13M15 29.5H27" stroke="#F5EFE7" />
      <path d="M9 28.5H11H9ZM13 28.5H15H13ZM9 29.5H11H9ZM13 29.5H15H13Z" fill="black" />
      <path d="M9 28.5H11M13 28.5H15M9 29.5H11M13 29.5H15" stroke="#EE3D3E" />
    </svg>
  )
}
