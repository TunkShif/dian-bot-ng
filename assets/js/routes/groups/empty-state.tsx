import type React from "react";

type EmptyStateProps = {
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: React.ReactNode;
};

export const EmptyState = ({ icon, title, description, action }: EmptyStateProps) => (
  <div className="flex min-h-56 flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/80 bg-muted/20 px-4 py-8 text-center">
    <div className="flex size-10 items-center justify-center rounded-xl bg-muted text-muted-foreground">{icon}</div>
    <div className="space-y-1">
      <h2 className="font-heading text-base font-medium text-foreground">{title}</h2>
      <p className="max-w-md text-sm text-muted-foreground">{description}</p>
    </div>
    {action}
  </div>
);
