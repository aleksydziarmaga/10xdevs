export type BudgetCategoryType = "needs" | "wants" | "savings";

// Monetary values are persisted in the smallest currency unit (for example cents/grosze).
export type MoneyAmount = number;

export interface WalletRow {
  id: string;
  owner_user_id: string;
  name: string;
  currency_code: string;
  guideline_needs_pct: number;
  guideline_wants_pct: number;
  guideline_savings_pct: number;
  created_at: string;
  updated_at: string;
}

export interface BudgetTemplateRow {
  id: string;
  wallet_id: string;
  name: string;
  monthly_income_amount: MoneyAmount;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface BudgetTemplateCategoryRow {
  id: string;
  template_id: string;
  name: string;
  category_type: BudgetCategoryType;
  monthly_amount: MoneyAmount;
  is_archived: boolean;
  created_at: string;
  updated_at: string;
}

export interface RecurringExpenseRow {
  id: string;
  template_id: string;
  name: string;
  category_type: BudgetCategoryType;
  monthly_amount: MoneyAmount;
  created_at: string;
  updated_at: string;
}

export interface SavingsGoalRow {
  id: string;
  template_id: string;
  name: string;
  target_monthly_amount: MoneyAmount;
  created_at: string;
  updated_at: string;
}

export interface MonthlyBudgetRow {
  id: string;
  wallet_id: string;
  template_id: string | null;
  period_year: number;
  period_month: number;
  monthly_income_amount: MoneyAmount;
  guideline_needs_pct: number;
  guideline_wants_pct: number;
  guideline_savings_pct: number;
  created_at: string;
  updated_at: string;
}

export interface ExpenseRow {
  id: string;
  wallet_id: string;
  monthly_budget_id: string;
  category_id: string | null;
  expense_date: string;
  amount: MoneyAmount;
  description: string | null;
  category_name: string;
  category_type: BudgetCategoryType;
  created_at: string;
  updated_at: string;
}

export interface CreateBudgetTemplateInput {
  wallet_id: string;
  name: string;
  monthly_income_amount: MoneyAmount;
}

export interface CreateMonthlyBudgetInput {
  wallet_id: string;
  template_id: string | null;
  period_year: number;
  period_month: number;
  monthly_income_amount: MoneyAmount;
  guideline_needs_pct: number;
  guideline_wants_pct: number;
  guideline_savings_pct: number;
}

export interface CreateExpenseInput {
  wallet_id: string;
  monthly_budget_id?: string;
  category_id?: string | null;
  expense_date: string;
  amount: MoneyAmount;
  description?: string | null;
  category_name?: string;
  category_type?: BudgetCategoryType;
}
