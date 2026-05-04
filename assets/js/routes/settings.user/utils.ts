import { format } from "date-fns";

const SETTINGS_DATE_FORMAT = "PP p";

export const formatSettingsDate = (value: string) => format(new Date(value), SETTINGS_DATE_FORMAT);
