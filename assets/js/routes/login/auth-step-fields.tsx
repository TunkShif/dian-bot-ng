import { useTranslation } from "react-i18next";
import { InputGroup, InputGroupAddon, InputGroupInput, InputGroupText } from "@/components/ui/input-group";

export const AuthHeader = ({ title, description }: { title: string; description: string }) => {
  return (
    <div className="flex flex-col items-center gap-2 text-center">
      <h1 className="text-2xl font-bold">{title}</h1>
      <p className="text-balance text-muted-foreground">{description}</p>
    </div>
  );
};

type QQEmailInputProps = {
  id: string;
  name?: string;
  readOnly?: boolean;
  value: string;
  onChange: (value: string) => void;
};

export const QQEmailInput = ({ id, name, readOnly, value, onChange }: QQEmailInputProps) => {
  const { t } = useTranslation();

  return (
    <InputGroup>
      <InputGroupInput
        id={id}
        type="text"
        name={name}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        inputMode="numeric"
        pattern="\d{5,13}"
        minLength={5}
        maxLength={13}
        placeholder={t("auth.login.emailInput.placeholder")}
        title={t("auth.login.emailInput.title")}
        required
        readOnly={readOnly}
      />
      <InputGroupAddon align="inline-end">
        <InputGroupText>{t("auth.login.emailInput.domain")}</InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
};
