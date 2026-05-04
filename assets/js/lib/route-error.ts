import { isRouteErrorResponse } from "react-router-dom";

const MAX_ERROR_DETAIL_LINES = 6;
const MAX_ERROR_DETAIL_LINE_LENGTH = 120;

export type RouteErrorTitleKey =
  | "app.errorBoundary.status.400.title"
  | "app.errorBoundary.status.401.title"
  | "app.errorBoundary.status.403.title"
  | "app.errorBoundary.status.404.title"
  | "app.errorBoundary.status.500.title"
  | "app.errorBoundary.fallback.title";

export type RouteErrorDescriptionKey =
  | "app.errorBoundary.status.400.description"
  | "app.errorBoundary.status.401.description"
  | "app.errorBoundary.status.403.description"
  | "app.errorBoundary.status.404.description"
  | "app.errorBoundary.status.500.description"
  | "app.errorBoundary.fallback.description";

type RouteErrorTranslationKeys = {
  titleKey: RouteErrorTitleKey;
  descriptionKey: RouteErrorDescriptionKey;
};

export const getRouteErrorTranslationKeys = (error: unknown): RouteErrorTranslationKeys => {
  if (!isRouteErrorResponse(error)) {
    return {
      titleKey: "app.errorBoundary.fallback.title",
      descriptionKey: "app.errorBoundary.fallback.description",
    };
  }

  switch (error.status) {
    case 400:
      return {
        titleKey: "app.errorBoundary.status.400.title",
        descriptionKey: "app.errorBoundary.status.400.description",
      };
    case 401:
      return {
        titleKey: "app.errorBoundary.status.401.title",
        descriptionKey: "app.errorBoundary.status.401.description",
      };
    case 403:
      return {
        titleKey: "app.errorBoundary.status.403.title",
        descriptionKey: "app.errorBoundary.status.403.description",
      };
    case 404:
      return {
        titleKey: "app.errorBoundary.status.404.title",
        descriptionKey: "app.errorBoundary.status.404.description",
      };
    case 500:
      return {
        titleKey: "app.errorBoundary.status.500.title",
        descriptionKey: "app.errorBoundary.status.500.description",
      };
    default:
      return {
        titleKey: "app.errorBoundary.fallback.title",
        descriptionKey: "app.errorBoundary.fallback.description",
      };
  }
};

export const formatRouteErrorDetails = (error: unknown) => {
  const details = getRouteErrorDetails(error);
  return truncateRouteErrorDetails(details);
};

const getRouteErrorDetails = (error: unknown) => {
  if (isRouteErrorResponse(error)) {
    return JSON.stringify(
      {
        status: error.status,
        statusText: error.statusText,
        data: error.data,
      },
      null,
      2,
    );
  }

  if (error instanceof Error) {
    return [error.name, error.message, error.stack].filter(Boolean).join("\n");
  }

  if (typeof error === "string") {
    return error;
  }

  try {
    return JSON.stringify(error, null, 2);
  } catch {
    return String(error);
  }
};

const truncateRouteErrorDetails = (details: string) => {
  const lines = details.split("\n");
  const truncatedLines = lines.slice(0, MAX_ERROR_DETAIL_LINES).map((line) => {
    if (line.length <= MAX_ERROR_DETAIL_LINE_LENGTH) return line;
    return `${line.slice(0, MAX_ERROR_DETAIL_LINE_LENGTH)}...`;
  });

  if (lines.length > MAX_ERROR_DETAIL_LINES) {
    truncatedLines.push("...");
  }

  return truncatedLines.join("\n");
};
